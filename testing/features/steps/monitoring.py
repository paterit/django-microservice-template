from behave import *
import requests


@given(u'URL for Grafana API')
def step_impl(context):
    context.DASHBOARD_URL = 'http://admin:admin@monitoring-server:80/api/dashboards/db/glances-graphite'


@when(u'API for dashboard for CPU is called')
def step_impl(context):
    context.response = requests.get(context.DASHBOARD_URL)


@then(u'data for dashboard is not empty')
def step_impl(context):
    r = context.response
    assert 200 == r.status_code
    assert '"dmtXOJASTmaGLgWHaOijgBV"' in str(r.content)
