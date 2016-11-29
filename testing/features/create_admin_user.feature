Feature: Login as a superuser to admin panel
  In order to use admin panel,
  As a superuser user
  I want to authenticate to system
  using standard test1 admin account

  Scenario: Login as admin user
    Given User login and passwrod entered on admin panel login url
     Then User is able to login