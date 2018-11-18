Feature: Check the performance tests
  In order to make sure that the performance of the web services is good enough
  As a developer
  I want to call run performance tests
  and verify that they fit into defined time frame


  @perftest
  Scenario Outline: Check pages response time
    Given Run perf tests for <period> seconds
    When performance tests are finished
    Then the main pape response time should be below <maxtime> ms

    Examples: Main page
        | period | maxtime |
        | 60     | 20      |