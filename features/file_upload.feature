Feature: Secure file uploads
  In order to have a files secured in wiki
  A user
  Should be able to upload files and inherit file permissions from pages

  Background:
    Given there are no files uploaded

  Scenario: User tries do download a bogus file
    When I go to /bogus_file.txt
    Then I should see "File not found."
    When I go to /a/nested/bogus_file.txt
    Then I should see "File not found."

  Scenario: User wants to upload a file
    When I go to the main page
    And I login as "johno"
    And I create "/" page
  #And I upload "test_file.txt" file
    And I follow "edit"
    And I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    When I go to /test_file.txt
    Then I should see "Some text in file."

  Scenario: User uploads a file under a restricted page and different user wants to download it
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And I follow "edit"
    And I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    And I logout
    When I go to /test_file.txt
    Then I should see "Permission denied."
    When I login as "crutch"
    And I go to /test_file.txt
    Then I should see "Permission denied."

  Scenario: User tries do download a bogus file and then upload it
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I go to /test_file2.txt
    Then I should see "File not found."
    When I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."

  Scenario: User tries do download a bogus file and then upload it with diffrent name
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I go to /bogus_file.txt
    Then I should see "File not found."
    When I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    When I go to /bogus_file.txt
    Then I should see "Some text in file."

  Scenario: User tries do download a bogus file and then upload difrent type of file
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I go to /bogus_still_file.txt
    Then I should see "File not found."
    When I attach the file at "picture.jpg" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "Type of file not match."
    When I go to /bogus_still_file.txt
    Then I should see "File not found."

  Scenario: User tries do download a bogus file
    When I go to /bogus_still_file.txt
    Then I should see "File not found."
    And I should not see "You can upload this file."

  Scenario: User tries do download a bogus file and then upload difrent type of file
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I create "/new_page/" page with file link
    And I go to /new_page/link.txt
    Then I should see "File not found."
    When I attach the file at "picture.jpg" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "Type of file not match."
    And I go to /new_page/link.txt
    Then I should see "File not found."

  Scenario: User tries do download a bogus file and then upload difrent type of file
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I create "/new_page/" page with file link
    And I go to /new_page/link.txt
    Then I should see "File not found."
    When I attach the file at "test_file2.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    And I go to /new_page/link.txt
    Then I should see "Some text in file."

  Scenario: User uploads some files and wants to see them all
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "edit"
    And I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    When I follow "edit"
    And I attach the file at "test_file2.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    When I follow "files"
    Then I should see "test_file.txt"
    And I should see "test_file2.txt"    

  Scenario: User uploads some files and wants to see them without listing subdirectories
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Edit"
    And I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    And I create "/nested/" page
    And I go to /nested/?edit
    And I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    And I go to the main page
    When I follow "Files"
    Then I should see "test_file.txt"
    And I should not see "nested"

  Scenario: User uploads no files and tries to view a listing
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Files"
    Then I should see "No files uploaded for this page"