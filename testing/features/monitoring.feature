Feature: Check if data from glances are visible in grafana
  In order to ensure that data from glances are shipped to grafana,
  As a developer
  I want to call grafana API
  and glances-graphite dashboard is available

  Scenario: Check CPU data
    Given URL for Grafana API
    When API for dashboard for CPU is called
    Then data for dashboard is not empty