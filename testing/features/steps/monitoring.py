from behave import *
import requests


@given(u'URL for Grafana API')
def step_impl(context):
    context.SYSTEM_DASHBOARD_URL = 'http://admin:admin@monitoring-server:80/api/dashboards/db/glances-graphite'
    context.PERFORMANCE_DASHBOARD_URL = 'http://admin:admin@monitoring-server:80/api/dashboards/db/performance-testing'


@when(u'API for dashboard for CPU is called')
def step_impl(context):
    context.response = requests.get(context.SYSTEM_DASHBOARD_URL)


@then(u'data for CPU dashboard is not empty')
def step_impl(context):
    r = context.response
    assert 200 == r.status_code
    assert '"dmtXOJASTmaGLgWHaOijgBV"' in str(r.content)


@when(u'API for dashboard for performance testing is called')
def step_impl(context):
    context.response = requests.get(context.PERFORMANCE_DASHBOARD_URL)


@then(u'data for performance testing is not empty')
def step_impl(context):
    r = context.response
    assert 200 == r.status_code, "URL: " + context.PERFORMANCE_DASHBOARD_URL
    assert '"dmtXOJASTmaGLgWHaOijgNB"' in str(r.content)
