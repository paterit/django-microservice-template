#!/usr/bin/env python
from locust import HttpLocust, TaskSet, task, events, web, runners
from statsd import StatsClient


STATS_USER_COUNT = "users"


@web.app.route("/dmt-perf-start")
def dmt_perf_start():
    print("DMT: Request to start hatching.")
    runners.locust_runner.start_hatching(10, 1)
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


class UserBehavior(TaskSet):
    """ Defines user behaviour in traffic simulation """

    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        statsd.gauge(STATS_USER_COUNT, 1, delta=True)
        self.login()

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """
        statsd.gauge(STATS_USER_COUNT, -1, delta=True)
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

    @task(2)
    def index(self):
        self.client.get("/")

    @task(1)
    def admin(self):
        self.client.get("/admin/")


class WebsiteUser(HttpLocust):
    """ Defines user that will be used in traffic simulation """
    task_set = UserBehavior
    min_wait = 3000
    max_wait = 5000


def get_stat_name(request_type, name):
    return request_type + name.replace('.', '-')


# hook that is fired each time the request ends up with success
def hook_request_success(request_type, name, response_time, response_length, **kw):
    stat_name = get_stat_name(request_type, name)
    statsd.timing(stat_name, response_time)


def hook_request_failure(request_type, name, response_time, **kw):
    stat_name = "failure." + get_stat_name(request_type, name)
    statsd.timing(stat_name, response_time)


def hook_locust_error(locust_instance, **kw):
    stat_name = "locust_errors." + type(locust_instance).__name__
    statsd.gauge(stat_name, 1, delta=True)


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
