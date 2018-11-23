Feature: Check the performance tests
  In order to make sure that the performance of the web services is good enough
  As a developer
  I want to call run performance tests
  and verify that they fit into defined time frame


 @perftest
  Scenario Outline: Check pages response time
    Given Run perf tests for <period> seconds with <clients_count> clients and with <clients_per_second> hatch rate
    When performance tests are finished
    Then the main pape response time should be below <maxtime> ms

    Examples: Main page
        | period | clients_count | clients_per_second | maxtime |
        | 120    | 30            | 5                  | 20      |