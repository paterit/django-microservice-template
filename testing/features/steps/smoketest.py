from behave import *
import requests


@given(u'Documentation url')
def step_impl(context):
    context.response = requests.get('http://https/docs/')


@then(u'Documentation page is properly loaded')
def step_impl(context):
    r = context.response
    assert 200 == r.status_code
    assert 'documentation' in str(r.content)


@given(u'Kibana url')
def step_impl(context):
    context.response = requests.get('http://logs:5601')


@then(u'Kibana home page is properly loaded')
def step_impl(context):
    r = context.response
    assert 200 == r.status_code
    assert 'kibana' in str(r.content)


@given(u'Django app url')
def step_impl(context):
    context.response = requests.get('http://https/admin')


@then(u'Django admin page is properly loaded')
def step_impl(context):
    r = context.response
    assert 200 == r.status_code
    assert 'admin' in str(r.content)
