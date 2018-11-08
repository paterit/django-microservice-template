#!/usr/bin/env python
from locust import HttpLocust, TaskSet, task, events
import locust.events
from statsd import StatsClient


class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        self.login()

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """
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
    task_set = UserBehavior
    min_wait = 3000
    max_wait = 5000


statsd = StatsClient(host='monitoring-server',
                     port=8125,
                     prefix="perf",
                     maxudpsize=512)


def hook_request_success(request_type, name, response_time, response_length, **kw):
    stat_name = request_type + name.replace('.', '-')
    statsd.timing(stat_name, response_time)
    statsd.incr(stat_name, 1)


events.request_success += hook_request_success
