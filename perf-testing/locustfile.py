#!/usr/bin/env python
from locust import HttpLocust, TaskSet, task, events, web, runners
from locust.exception import StopLocust
from statsd import StatsClient
from flask import request

# name of the statistic for number of active testing clients that are sent over statsd to graphite
STATS_USER_COUNT = "{{ project_name }}-users"
# values used in *.feature files to indicate if client should login / logout during tests execution
LOGGED_USER = "logged"
NOT_LOGGED_USER = "notlogged"
# name of the statistic for requests that are sent over statsd to graphite
STAT_NAME = "{{ project_name }}-perf-test"
FAILUER_STAT_NAME = "failure." + STAT_NAME
LOCUST_ERROR_STAT_NAME = "locust_error." + STAT_NAME


@web.app.route("/dmt-perf-start")
def dmt_perf_start():
    print("DMT: Request to start hatching.")
    locust_count = request.args.get("locust_count", 10, type=int)
    hatch_rate = request.args.get("hatch_rate", 1, type=int)
    runners.locust_runner.dmt_test_url = request.args.get("test_url", None)
    runners.locust_runner.dmt_logged_user = request.args.get("logged_user", NOT_LOGGED_USER)

    runners.locust_runner.start_hatching(locust_count, hatch_rate)
    return "OK"


@web.app.route("/dmt-perf-stop")
def dmt_perf_stop():
    print("DMT: Request to stop.")
    runners.locust_runner.stop()
    return "OK"


# client to connect statsd server that collects metrics for Graphite
statsd = StatsClient(host='monitoring-server',
                     port=8125,
                     prefix="perf",
                     maxudpsize=512)


class UserTask(TaskSet):
    """ Defines user behaviour in traffic simulation """

    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        statsd.gauge(STATS_USER_COUNT, 1, delta=True)
        if self.locust.logged_user == LOGGED_USER:
            self.login()

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """
        statsd.gauge(STATS_USER_COUNT, -1, delta=True)
        if self.locust.logged_user == LOGGED_USER:
            self.logout()

    def login(self):
        response = self.client.get('/admin/')
        csrftoken = response.cookies['csrftoken']
        self.client.post('/admin/login/',
                         {'username': 'admin', 'password': 'admin', "csrfmiddlewaretoken": csrftoken},
                         headers={'X-CSRFToken': csrftoken},
                         cookies={"csrftoken": csrftoken})

    def logout(self):
        self.client.get("/admin/logout/")

    @task()
    def index(self):
        self.client.get(self.locust.test_url)


class User(HttpLocust):
    test_url = None
    logged_user = None
    task_set = UserTask
    min_wait = 1000
    max_wait = 2000

    def run(self, runner):
        if runner:
            self.test_url = runner.dmt_test_url
            self.logged_user = runner.dmt_logged_user
        if self.test_url is None:
            raise StopLocust("DMT: test_url for " + self.__class__.__name__ + " is None.")
        super(User, self).run(runner)


# hook that is fired each time the request ends up with success
def hook_request_success(request_type, name, response_time, response_length, **kw):
    statsd.timing(STAT_NAME, response_time)


def hook_request_failure(request_type, name, response_time, **kw):
    statsd.timing("failure." + STAT_NAME, response_time)


def hook_locust_error(locust_instance, **kw):
    statsd.gauge(LOCUST_ERROR_STAT_NAME, 1, delta=True)


def hook_locust_stop_hatching():
    statsd.gauge(STATS_USER_COUNT, 0)
    print("DMT: hook_locust_stop_hatching executed")


def hook_locust_start_hatching():
    statsd.gauge(STATS_USER_COUNT, 0)
    print("DMT: hook_locust_start_hatching executed")


events.request_success += hook_request_success
events.request_failure += hook_request_failure
events.locust_error += hook_locust_error
events.locust_stop_hatching += hook_locust_stop_hatching
events.locust_start_hatching += hook_locust_start_hatching
