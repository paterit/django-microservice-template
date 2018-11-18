from behave import *
import json
import requests
import time


@given(u'Run perf tests for {period} seconds')
def step_impl(context, period):
    context.PERF_START_URL = 'http://perf:8089/dmt-perf-start'
    context.PERF_STOP_URL = 'http://perf:8089/dmt-perf-stop'
    context.RESPONSE_TIMES_URL = 'http://monitoring-server:81/render?target=stats.timers.perf.GET-.mean_95&format=json&from=-' + str(period) + 'seconds'

    context.response_stop = requests.get(context.PERF_STOP_URL)
    assert 200 == context.response_stop.status_code
    context.response_start = requests.get(context.PERF_START_URL)
    assert 200 == context.response_start.status_code
    time.sleep(int(period))

@when(u'performance tests are finished')
def step_impl(context):
    context.response_stop = requests.get(context.PERF_STOP_URL)
    assert 200 == context.response_stop.status_code

@then(u'the main pape response time should be below {maxtime} ms')
def step_impl(context, maxtime):
    context.response_times = requests.get(context.RESPONSE_TIMES_URL)
    assert 200 == context.response_times.status_code
    jr = json.loads(context.response_times.text)
    times = [row[0] for row in jr[0]['datapoints'] if row[0] is not None]
    assert len(times) != 0, "Repsonse times array is empty!"
    average = sum(times) / len(times)
    assert average < float(maxtime), "Average response time is " + str(average) + " ms"
