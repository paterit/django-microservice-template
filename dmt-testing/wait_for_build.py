""" Waiting for build with given numberin Buildbot to be done when Buildbot is runnign on the local machine """
import requests
import time
import sys
import pprint

ERR_NO_BUILDBOT = 1
ERR_BUILD_FAIL = 2
SUCCESS = 0
MAX_RETRY = 30

# Buildbot enumerates builds starting with number 1
build_number = sys.argv[1]

r = requests.get("http://localhost:8010/api/v2/builds/%s" % (build_number))
count = 0
# wait loop for waiting build to get started
while (r.status_code != 200):
    time.sleep(1)
    r = requests.get("http://localhost:8010/api/v2/builds/%s" % (build_number))
    if (r.status_code != 200):
        print("Build not started yet. Response code: %d. Retrying ..." % r.status_code)
        count += 1
        if (count >= MAX_RETRY):
            exit(ERR_NO_BUILDBOT)
    else:
        print("OK. Build machine responded with %d." % (r.status_code))

# wait loop for waiting build to be finished
while (True):
    r = requests.get("http://localhost:8010/api/v2/builds/%s" % (build_number))
    result = r.json()["builds"][0]["results"]
    state = r.json()["builds"][0]["state_string"]

    if (state == "building" or state == "acquiring locks"):
        print("Current build status is: '%s' ..." % (state))
        time.sleep(10)
    else:
        try:
            print("Returned code (results) for this build is: '%d'" % (result))
        except TypeError:
            print("Problem! Rusult returned from Buildbot is %s and the state is %s" % (str(result), state))
            print(r.json()["builds"][0])

        if (result != 0):
            pprint.PrettyPrinter(indent=4).pprint(r.json()["builds"][0])
            print("Building failed with results code: %s" % (result))
            exit(ERR_BUILD_FAIL)
        else:
            exit(SUCCESS)
