Feature: Check if all subsystems are available
  In order to ensure that all subsystems are up and runing,
  As a developer
  I want to call subsystems
  by using their specific healtchecks

  @smoketest
  Scenario: Check documentation page
    Given Documentation url
     Then Documentation page is properly loaded

  @smoketest
  Scenario: Check Kibana availability
    Given Kibana url
     Then Kibana home page is properly loaded

  @smoketest
  Scenario: Check Django admin page availability
    Given Django app url
     Then Django admin page is properly loaded

  @smoketest
  Scenario: Check Grafana login page availability
    Given Grafana url
     Then Grafana login page is properly loaded 

  @smoketest
  Scenario: Check Portainer availability
    Given Portainer url
     Then Portainer auth page is propely loaded

  @smoketest
  Scenario: Check Locust availability
    Given Locust url
     Then Locust start page is propely loaded
