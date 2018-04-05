from behave import *
import requests

WEB_URL = 'http://logs:9200/_count?q=containername:{{ project_name }}-web&pretty'
HTTPS_URL = 'http://logs:9200/_count?q=containername:{{ project_name }}-https&pretty'


@given(u'web admin page for auth groups is loaded')
def step_impl(context):
    context.browser.get('http://{{ project_name }}-web:8000/admin/logout')
    context.browser.get('http://{{ project_name }}-web:8000/admin/login')
    context.browser.find_element_by_id('id_username').send_keys('admin')
    context.browser.find_element_by_id('id_password').send_keys('admin')
    context.browser.find_element_by_id('login-form').submit()

@when(u'elasticsearch API is called')
def step_impl(context):
    context.response_web = requests.get(WEB_URL)
    context.response_https = requests.get(HTTPS_URL)

@then(u'query for web container returns none zero results')
def step_impl(context):
    r = context.response_web
    assert 200 == r.status_code
    assert '"count" : 0' not in str(r.content)

@then(u'query for https container returns none zero results')
def step_impl(context):
    r = context.response_https
    assert 200 == r.status_code
    assert '"count" : 0' not in str(r.content)
