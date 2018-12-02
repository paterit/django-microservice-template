import os
import requests
import sys
from subprocess import run
from packaging.version import parse
from plumbum.cmd import sed
from cachier import cachier  # pip install pymongo to avoid warning
import datetime
from rex import rex


# based on https://github.com/al4/docker-registry-list/blob/master/docker-registry-list.py
@cachier(stale_after=datetime.timedelta(days=3))
def fetch_versions(image_name):
    print("NOT CACHED")
    payload = {
        'service': 'registry.docker.io',
        'scope': 'repository:library/{image}:pull'.format(image=image_name)
    }

    r = requests.get('https://auth.docker.io' + '/token', params=payload)
    if not r.status_code == 200:
        print("Error status {}".format(r.status_code))
        raise Exception("Could not get auth token")

    j = r.json()
    token = j['token']
    h = {'Authorization': "Bearer {}".format(token)}
    r = requests.get('{}/v2/library/{}/tags/list'.format("https://index.docker.io", image_name),
                     headers=h)
    return r.json()


# sed -i "s|DOCKER_TLS_VERIFY\=$|DOCKER_TLS_VERIFY\=$DOCKER_TLS_VERIFY|" ./Makefile
def replace_version(old, new, files):
    counter = 0
    base_dir = os.getcwd() + "/../"
    for file in files:
        ret = sed['-n', 's|' + old + '|' + new + '|p', base_dir + file].run(retcode=None)
        if ret[0] != 0:
            print("Error in version replacment: sed error")
            print(ret)
            exit(1)
        if ret[1] == '':
            print("Error in version replacment: no replacement done")
            print(ret)
            exit(1)
        ret = sed['-i', 's|' + old + '|' + new + '|', base_dir + file].run(retcode=None)
        counter += 1
    return counter


COMPONENTS = ('postgres', 'nginx')
CURRENT_VERSIONS = {
    "postgres": "10.3-alpine",
    "nginx": "1.13-alpine"
}
SRC = {
    "postgres": (
        "cicd/db/Dockerfile",
        "db/Dockerfile-db",
        "db/Dockerfile-data",
        "cicd/copy_docker_images_to_machine.sh",
        "cicd/pull_base_docker_images.sh"),
    "nginx": (
        "https/Dockerfile-https",
        "cicd/copy_docker_images_to_machine.sh",
        "cicd/pull_base_docker_images.sh")
}
FILTERS = {
    "postgres": '/.*alpine$/',
    "nginx": '/.*alpine$/'
}

if len(sys.argv) < 2:
    print("No argument. At least one component is needed.")
    sys.exit(1)

component = sys.argv[1]

if component not in (COMPONENTS):
    print("Not supported component.")
    sys.exit(1)

newer_versions = {}

tags = fetch_versions(component)["tags"]
curr = parse(CURRENT_VERSIONS[component])
highest = max([parse(tag) for tag in tags if tag == rex(FILTERS[component])])

if highest > curr:
    newer_versions[component] = (str(curr), str(highest))

replace_version(
    component + ":" + str(curr),
    component + ":" + str(highest),
    SRC[component])

ret = run(["time", "make", "test"])
print(ret.returncode)
print(newer_versions)
print("Update " + next(iter(newer_versions) + " to " + newer_versions[component][1]))
