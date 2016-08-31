Feature: Create {{ project_name }} user for admin panel
  In order tu use admin panel,
  As a new user
  I want to authenticate to system
  using standard {{ project_name }} admin account

  Scenario: Add {{ project_name }} user
    Given User login and passwrod
     When Calling API for adding user
     Then New user is able to login to 