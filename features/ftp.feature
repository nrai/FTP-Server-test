Feature: Login User
 In Order to upload/download files
 As a user
 I want to login

 Scenario: Log on
  Given I have username and password
  And I have correct credentials 
  When I need to login
  Then I should enter crendentials
  And I should be able to successfully login


 Scenario: List a Directory
 Given I am logged in
 When I need directory listings
 Then I should get a list of all sub directories in the current Directory.

 Scenario: Upload a File
 Given I am logged in
 When I need to upload a file
 Then I should i should be able to upload the file
 And View Contents in the direcory listings

