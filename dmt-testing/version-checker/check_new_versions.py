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
import yaml


TESTS_SUCCESS = 0
GIT_COMMAND_SUCCESS = 0
RUN_PERF_TESTS = True
EXIT_ERROR = 1
EXIT_SUCCESS = 0
BASE_DIR = os.getcwd() + "/../../"
DRY_RUN = True  # if True no git commit is made at the end of process
FAST_TESTS = True  # if True no make test is run. make hello is called instead
SEPARATOR = {"docker-image": ":", "pip": "=="}

pp = pprint.PrettyPrinter(indent=4)

COMPONENTS = yaml.load(open("components.yaml"))


def kill(exit_code, message, val_to_pprint=None):
    print(message)
    if val_to_pprint:
        pp.pprint(val_to_pprint)
    sys.exit(exit_code)


# based on https://github.com/al4/docker-registry-list/blob/master/docker-registry-list.py
@cachier(stale_after=datetime.timedelta(days=3))
def fetch_versions(component):
    COMP = COMPONENTS[component]
    if COMP["type"] == "docker-image":
        repo_name = COMP["docker-repo"]
        print(repo_name + SEPARATOR[COMP["type"]] + component + " - NOT CACHED")
        payload = {
            'service': 'registry.docker.io',
            'scope': 'repository:{repo}/{image}:pull'.format(repo=repo_name, image=component)
        }

        r = requests.get('https://auth.docker.io/token', params=payload)
        if not r.status_code == 200:
            print("Error status {}".format(r.status_code))
            raise Exception("Could not get auth token")

        j = r.json()
        token = j['token']
        h = {'Authorization': "Bearer {}".format(token)}
        r = requests.get('https://index.docker.io/v2/{}/{}/tags/list'.format(repo_name, component),
                         headers=h)
        return r.json()["tags"]
    elif COMP["type"] == "pip":
        r = requests.get('https://pypi.org/pypi/{}/json'.format(component))
        return list(r.json()["releases"].keys())


def replace_version(old, new, files):
    counter = 0
    for file in files:
        ret = sed['-n', 's|' + old + '|' + new + '|p', BASE_DIR + file].run(retcode=None)
        if ret[0] != 0:
            kill(EXIT_ERROR, "Error in version replacment: sed error", ret)
        if ret[1] == '':
            kill(EXIT_ERROR, "Error in version replacment: no replacement done for: " + old, ret)
        ret = sed['-i', 's|' + old + '|' + new + '|', BASE_DIR + file].run(retcode=None)
        counter += 1
    return counter


def add_file_to_commit(file):
    ret_git = git["add", BASE_DIR + file].run(retcode=None)
    if ret_git[0] is not GIT_COMMAND_SUCCESS:
        kill(EXIT_ERROR, "Probelm with git add!", ret_git)


def save_yaml(component, new_version):
    COMPONENTS[component]['current_version'] = new_version
    yaml.dump(COMPONENTS, open("components.yaml", "w"))
    add_file_to_commit('dmt-testing/version-checker/components.yaml')


if len(sys.argv) < 2:
    component_list = COMPONENTS.keys()
else:
    component_list = sys.argv[1:]


if __name__ == "__main__":

    # for components that are docker images
    for component in component_list:
        assert component in (COMPONENTS.keys()), "Not supported component: " + component
        print("Starting with " + component + " ...")
        COMP = COMPONENTS[component]

        tags = fetch_versions(component)

        # for latest versions, where no newer versions exist, print found tags and skip
        if COMP["current_version"] == "latest":
            print("For " + component + " is set 'latest' version. Skip.")
            print("Current tags are: " + str(tags))
            continue

        highest = max([parse(tag) for tag in tags
                       if (tag == rex(COMP.get("filter", "/.*/")) and
                           tag not in COMP.get("exclude-versions", [])
                           )
                       ])
        curr = parse(COMP["current_version"])

        curr_str = COMP.get("prefix", "") + str(curr)
        highest_str = COMP.get("prefix", "") + str(highest)

        commit_message = "Update " + component + " to " + highest_str + " from " + curr_str

        if highest > curr:
            replace_version(
                component + SEPARATOR[COMP["type"]] + curr_str,
                component + SEPARATOR[COMP["type"]] + highest_str,
                COMP["files"])

            if FAST_TESTS:
                ret = run(["make", "hello"], cwd='../')
            else:
                ret = run(["make", "test"], cwd='../')

            if ret.returncode is not TESTS_SUCCESS:
                kill(EXIT_ERROR, "Make went wrong!", ret)

            # get from git list of changed files
            ret_git = git["diff", "--name-only"].run(retcode=None)
            changed_files = ret_git[1].splitlines()
            # check if all filers from SRC are in changed_files
            if not set(COMP["files"]).issubset(set(changed_files)):
                kill(EXIT_ERROR, "Not all SRC files are in git changed files.")

            for file in COMP["files"]:
                add_file_to_commit(file)

            save_yaml(component, highest_str)

            print("Files are ready for commit.")
            if not DRY_RUN:
                ret_git = git["commit", "-m", "'" + commit_message + "'"].run(retcode=None)
                if ret_git[0] is not GIT_COMMAND_SUCCESS:
                    kill(EXIT_ERROR, "Probelm with git commit!")

            print(commit_message)
        else:
            print("No newer version for " + component + " than " + curr_str + ". (found " + highest_str + " )")
