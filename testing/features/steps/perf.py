from behave import *
import json
import requests
import time


@given(u'Run perf tests by {period} seconds with {clients_count} clients and with {clients_per_second} hatch rate, with the test url: {test_url} for {logged_user} users')
def step_impl(context, period, clients_count, clients_per_second, test_url, logged_user):
    context.PERF_START_URL = 'http://perf:8089/dmt-perf-start?locust_count=' + clients_count \
                             + '&hatch_rate=' + clients_per_second \
                             + '&test_url=' + test_url \
                             + '&logged_user=' + logged_user
    context.PERF_STOP_URL = 'http://perf:8089/dmt-perf-stop'
    context.RESPONSE_TIMES_URL = 'http://monitoring-server:81/render?target=stats.timers.perf.{{ project_name }}-perf-test.mean_95&format=json&from=-' + str(period) + 'seconds'

    context.response_stop = requests.get(context.PERF_STOP_URL)
    assert 200 == context.response_stop.status_code
    context.response_start = requests.get(context.PERF_START_URL)
    assert 200 == context.response_start.status_code
    time.sleep(int(period))

@when(u'performance tests are finished')
def step_impl(context):
    context.response_stop = requests.get(context.PERF_STOP_URL)
    assert 200 == context.response_stop.status_code

@then(u'the response time should be below {maxtime} ms')
def step_impl(context, maxtime):
    context.response_times = requests.get(context.RESPONSE_TIMES_URL)
    assert 200 == context.response_times.status_code
    jr = json.loads(context.response_times.text)
    times = [round(row[0], 2) for row in jr[0]['datapoints'] if row[0] is not None]
    assert len(times) != 0, "Repsonse times array is empty!"
    average = round(sum(times) / len(times), 2)
    assert average < float(maxtime), \
        "Average response time is " + str(average) + " ms in series " + str(times)
