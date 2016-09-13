from behave import *


@given(u'User login and passwrod entered on admin panel login url')
def step_impl(context):
    context.browser.get('http://{{ project_name }}-web:8000/admin/login')
    context.browser.find_element_by_id('id_username').send_keys('admin')
    context.browser.find_element_by_id('id_password').send_keys('admin')
    context.browser.find_element_by_id('login-form').submit()


@then(u'User is able to login')
def step_impl(context):
    assert 'Site administration' in context.browser.title
