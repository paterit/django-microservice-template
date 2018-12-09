import os
import requests
import sys
from subprocess import run
from packaging.version import parse
from plumbum.cmd import sed, git
from cachier import cachier  # pip install pymongo to avoid warning
import datetime
from rex import rex
import pprint


TESTS_SUCCESS = 0
GIT_COMMAND_SUCCESS = 0
RUN_PERF_TESTS = True
EXIT_ERROR = 1
EXIT_SUCCESS = 0
BASE_DIR = os.getcwd() + "/../"
DRY_RUN = True

pp = pprint.PrettyPrinter(indent=4)

COMPONENTS = {
    "postgres": {
        "current_version": "10.3-alpine",
        "type": "docker-image",
        "repo": "library",
        "src": (
            "cicd/db/Dockerfile",
            "db/Dockerfile-db",
            "db/Dockerfile-data",
            "cicd/copy_docker_images_to_machine.sh",
            "cicd/pull_base_docker_images.sh"),
        "filter": "/.*alpine$/"
    },
    "nginx": {
        "current_version": "1.13-alpine",
        "type": "docker-image",
        "repo": "library",
        "src": (
            "https/Dockerfile-https",
            "cicd/copy_docker_images_to_machine.sh",
            "cicd/pull_base_docker_images.sh"),
        "filter": "/.*alpine$/"
    },
    "elk": {
        "current_version": "623",
        "type": "docker-image",
        "repo": "sebp",
        "src": (
            "logs/Dockerfile",
            "cicd/copy_docker_images_to_machine.sh",
            "cicd/pull_base_docker_images.sh"),
        "filter": "/^\d{3}$/"
    },
    "logspout": {
        "current_version": "v3.1",
        "type": "docker-image",
        "repo": "gliderlabs",
        "src": (
            "docker-compose.yml",
            "cicd/copy_docker_images_to_machine.sh",
            "cicd/pull_base_docker_images.sh"),
        "filter": "/^v\d.\d.\d$/",
        "prefix": "v"
    },
    "buildbot-master": {
        "current_version": "v1.1.0",
        "type": "docker-image",
        "repo": "buildbot",
        "src": ("cicd/master/Dockerfile",),
        "filter": "/^v\d.\d.\d$/",
        "prefix": "v",
        "exclude-versions": ("v1.6.0",)
    }
}


def kill(exit_code, message, val_to_pprint=None):
    print(message)
    if val_to_pprint:
        pp.pprint(val_to_pprint)
    sys.exit(exit_code)


# based on https://github.com/al4/docker-registry-list/blob/master/docker-registry-list.py
@cachier(stale_after=datetime.timedelta(days=3))
def fetch_versions(image_name, repo_name):
    print(repo_name + ":" + image_name + " - NOT CACHED")
    payload = {
        'service': 'registry.docker.io',
        'scope': 'repository:{repo}/{image}:pull'.format(repo=repo_name, image=image_name)
    }

    r = requests.get('https://auth.docker.io' + '/token', params=payload)
    if not r.status_code == 200:
        print("Error status {}".format(r.status_code))
        raise Exception("Could not get auth token")

    j = r.json()
    token = j['token']
    h = {'Authorization': "Bearer {}".format(token)}
    r = requests.get('{}/v2/{}/{}/tags/list'.format("https://index.docker.io", repo_name, image_name),
                     headers=h)
    return r.json()


def replace_version(old, new, files):
    counter = 0
    for file in files:
        ret = sed['-n', 's|' + old + '|' + new + '|p', BASE_DIR + file].run(retcode=None)
        if ret[0] != 0:
            kill(EXIT_ERROR, "Error in version replacment: sed error", ret)
        if ret[1] == '':
            kill(EXIT_ERROR, "Error in version replacment: no replacement done", ret)
        ret = sed['-i', 's|' + old + '|' + new + '|', BASE_DIR + file].run(retcode=None)
        counter += 1
    return counter


def stop_if_testing(val_to_pprint=None):
    if DRY_RUN:
        kill(EXIT_SUCCESS, "Stop here. Testing!", val_to_pprint)


if len(sys.argv) < 2:
    kill(EXIT_ERROR, "No argument. At least one component is needed.")


if __name__ == "__main__":

    # for components that are docker images
    for component in sys.argv[1:]:
        assert component in (COMPONENTS.keys()), "Not supported component"

        newer_versions = {}
        COMP = COMPONENTS[component]

        tags = fetch_versions(component, COMP["repo"])["tags"]
        highest = max([parse(tag) for tag in tags
                       if (tag == rex(COMP["filter"]) and
                           tag not in COMP.get("exclude-versions", [])
                           )
                       ])
        curr = parse(COMP["current_version"])
        if highest > curr:
            curr_str = COMP.get("prefix", "") + str(curr)
            highest_str = COMP.get("prefix", "") + str(highest)
            newer_versions[component] = (curr_str, highest_str)

        commit_message = "Update " + component + " to " + highest_str + " from " + curr_str
        stop_if_testing(commit_message)

        replace_version(
            component + ":" + curr_str,
            component + ":" + highest_str,
            COMP["src"])

        # ret = run(["make", "clean-local", "all-local"])
        ret = run(["make", "hello"])
        # ret = run(["make", "clean-local", "all-local", "test-perf", "clean-local", "clean", "all", "clean"])
        if ret.returncode is not TESTS_SUCCESS:
            kill(EXIT_ERROR, "Make went wrong!", ret)

        # get from git list of changed files
        ret_git = git["diff", "--name-only"].run(retcode=None)
        changed_files = ret_git[1].splitlines()
        # check if all filers from SRC are in changed_files
        if not set(COMP["src"]).issubset(set(changed_files)):
            kill(EXIT_ERROR, "Not all SRC files are in git changed files.")

        for file in COMP["src"]:
            ret_git = git["add", BASE_DIR + file].run(retcode=None)
            if ret_git[0] is not GIT_COMMAND_SUCCESS:
                kill(EXIT_ERROR, "Probelm with git add!", ret_git)

        print("Files are ready for commit.")
        ret_git = git["commit", "-m", "'" + commit_message + "'"].run(retcode=None)
        if ret_git[0] is not GIT_COMMAND_SUCCESS:
            kill(EXIT_ERROR, "Probelm with git commit!")

        print(commit_message)
