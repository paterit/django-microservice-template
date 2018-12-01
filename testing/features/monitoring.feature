Feature: Check if data from glances are visible in grafana
  In order to ensure that data from glances are shipped to grafana,
  As a developer
  I want to call grafana API
  and glances-graphite dashboard is available

  @standard
  Scenario: Check CPU data
    Given URL for Grafana API
    When API for dashboard for CPU is called
    Then data for CPU dashboard is not empty

  @standard
  Scenario: Chcek performance testing dashboard
    Given URL for Grafana API
    When API for dashboard for performance testing is called
    Then data for performance testing is not empty