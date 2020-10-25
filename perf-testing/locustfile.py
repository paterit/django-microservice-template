#!/usr/bin/env python
from locust import HttpUser, TaskSet, task, events, runners
from locust.exception import StopUser
from statsd import StatsClient
from flask import request
import logging

# name of the statistic for number of active testing clients that are sent over statsd to graphite
STATS_USER_COUNT = "{{ project_name }}-users"
# values used in *.feature files to indicate if client should login / logout during tests execution
LOGGED_USER = "logged"
NOT_LOGGED_USER = "notlogged"
# name of the statistic for requests that are sent over statsd to graphite
STAT_NAME = "{{ project_name }}-perf-test"
FAILUER_STAT_NAME = "failure." + STAT_NAME
LOCUST_ERROR_STAT_NAME = "locust_error." + STAT_NAME


@events.init.add_listener
def on_locust_init(web_ui, **kw):

    @web_ui.app.route("/dmt-perf-start")
    def dmt_perf_start():
        logging.info("DMT: Request to start hatching.")
        user_count = request.args.get("locust_count", 10, type=int)
        hatch_rate = request.args.get("hatch_rate", 1, type=int)
        web_ui.environment.runner.dmt_test_url = request.args.get("test_url", None)
        web_ui.environment.runner.dmt_logged_user = request.args.get("logged_user", NOT_LOGGED_USER)

        web_ui.environment.runner.start_hatching(user_count, hatch_rate)
        logging.info("DMT: Hatching request started for url: " + web_ui.environment.runner.dmt_test_url)

        return "OK"

    @web_ui.app.route("/dmt-perf-stop")
    def dmt_perf_stop():
        logging.info("DMT: Request to stop.")
        web_ui.environment.runner.stop()
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
        if self.user.logged_user == LOGGED_USER:
            self.login()

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """
        statsd.gauge(STATS_USER_COUNT, -1, delta=True)
        if self.user.logged_user == LOGGED_USER:
            self.logout()

    def login(self):
        response = self.user.client.get('/admin/')
        csrftoken = response.cookies['csrftoken']
        self.user.client.post('/admin/login/',
                         {'username': 'admin', 'password': 'admin', "csrfmiddlewaretoken": csrftoken},
                         headers={'X-CSRFToken': csrftoken},
                         cookies={"csrftoken": csrftoken})

    def logout(self):
        self.user.client.get("/admin/logout/")

    @task()
    def index(self):
        self.user.client.get(self.user.host)


class DMTUser(HttpUser):
    host = None
    logged_user = None
    tasks = {UserTask:2}
    min_wait = 1000
    max_wait = 2000

    def run(self):
        if self.environment.runner:
            self.host = self.environment.runner.dmt_test_url
            self.logged_user = self.environment.runner.dmt_logged_user
        if self.host is None:
            raise StopUser("DMT: test_url for " + self.__class__.__name__ + " is None.")
        super(DMTUser, self).run()


@events.request_success.add_listener
def hook_request_success(request_type, name, response_time, response_length, **kw):
    statsd.timing(STAT_NAME, response_time)


@events.request_failure.add_listener
def hook_request_failure(request_type, name, response_time, response_length, **kw):
    statsd.timing("failure." + STAT_NAME, response_time)


@events.user_error.add_listener
def hook_locust_error(user_instance, exception, tb, **kw):
    statsd.gauge(LOCUST_ERROR_STAT_NAME, 1, delta=True)

@events.test_stop.add_listener
def hook_locust_stop_hatching(**kw):
    statsd.gauge(STATS_USER_COUNT, 0)
    logging.info("DMT: hook_locust_stop_hatching executed")


@events.test_start.add_listener
def hook_locust_start_hatching(**kw):
    statsd.gauge(STATS_USER_COUNT, 0)
    logging.info("DMT: hook_locust_start_hatching executed")
