Feature: Check the performance tests
  In order to make sure that the performance of the web services is good enough
  As a developer
  I want to run performance tests
  and verify that mean response times are below threshold

  @slow
  @perftest
  Scenario Outline: Check pages response time
    Given running performance tests for <period> seconds with <clients_count> clients and with <clients_per_second> hatch rate, with the test url: <test_url> for <logged_user> users
    When performance tests are finished
    Then the response time should be below <maxtime> ms

    Examples: Long tests with given test_url
        | period | clients_count | clients_per_second | test_url | logged_user | maxtime |
        | 300    | 500           | 10                 | /        | notlogged   | 500     |
        | 60     | 10            | 5                  | /admin/  | notlogged   | 100     |
        | 300    | 500           | 5                  | /        | logged      | 500     |
        | 30     | 1             | 1                  | /        | notlogged   | 2000    |
        | 60     | 10            | 5                  | /admin/  | logged      | 100      |


  @standard
  @perftest
  Scenario Outline: Check pages response time in quicktest
    Given running performance tests for <period> seconds with <clients_count> clients and with <clients_per_second> hatch rate, with the test url: <test_url> for <logged_user> users
    When performance tests are finished
    Then the response time should be below <maxtime> ms

    Examples: Quick tests with given test_url
        | period | clients_count | clients_per_second | test_url | logged_user | maxtime |
        | 20     | 10            | 5                  | /        | notlogged   | 50      |


@perfsmoke
  Scenario Outline: Check pages response time in quicktest
    Given running performance tests for <period> seconds with <clients_count> clients and with <clients_per_second> hatch rate, with the test url: <test_url> for <logged_user> users
    When performance tests are finished
    Then the response time should be below <maxtime> ms

    Examples: Quick tests with given test_url
        | period | clients_count | clients_per_second | test_url | logged_user | maxtime |
        | 20     | 10            | 5                  | /        | notlogged   | 50      |
