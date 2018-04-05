Feature: Check if logs from containers are agregated in ELK
  In order to ensure that logs from containers are shipped to ELK,
  As a developer
  I want to call ELK API
  and count query result for each container

  Scenario: Check web app logs
    Given web admin page for auth groups is loaded
    When elasticsearch API is called
    Then query for web container returns none zero results
     and query for https container returns none zero results