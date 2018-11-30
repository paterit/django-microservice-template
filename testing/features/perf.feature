Feature: Check the performance tests
  In order to make sure that the performance of the web services is good enough
  As a developer
  I want to call run performance tests
  and verify that they fit into defined time frame


 @perftest
  Scenario Outline: Check pages response time
    Given Run perf tests by <period> seconds with <clients_count> clients and with <clients_per_second> hatch rate, with the test url: <test_url> for <logged_user> users
    When performance tests are finished
    Then the response time should be below <maxtime> ms

    Examples: Main public page and main admin page
        | period | clients_count | clients_per_second | test_url | logged_user | maxtime |
        | 600    | 500           | 10                 | /        | notlogged   | 500     |
        | 60     | 10            | 5                  | /admin/  | notlogged   | 50      |
        | 600    | 500           | 5                  | /        | logged      | 500     |
        | 60     | 10            | 5                  | /admin/  | logged      | 50      |
