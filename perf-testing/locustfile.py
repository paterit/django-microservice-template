#!/usr/bin/env python
from locust import HttpLocust, TaskSet, task


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
