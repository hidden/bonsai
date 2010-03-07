Feature: Secure file uploads
  In order to have a files secured in wiki
  A user
  Should be able to upload files and inherit file permissions from pages

  Background:
    Given there are no files uploaded
    And I am logged in

  Scenario: User tries do download a bogus file
    When I create "/" page
    And I logout
    And I go to /bogus_file.txt
    Then I should see "File not found."
    When I go to /a/nested/bogus_file.txt
    Then I should see "File not found."

  Scenario: User wants to upload a file
    When I create "/" page
  #And I upload "test_file.txt" file
    And I follow "edit"
    And I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Save"
    Then I should see "Page successfully updated."
    When I go to /test_file.txt
    Then I should see "Some text in file."

  Scenario: User uploads a file under a restricted page and different user wants to download it
    Given I am not logged in
    When I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And I follow "edit"
    And I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Save"
    And I logout
    When I go to /test_file.txt
    Then I should see "Permission denied."
    When I login as "crutch"
    And I go to /test_file.txt
    Then I should see "Permission denied."

  Scenario: User tries do download a bogus file and then upload it
    When I create "/" page
    And I go to /test_file2.txt
    Then I should see "File not found."
    When I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."

  Scenario: User tries do download a bogus file and then upload it with diffrent name
    When I create "/" page
    And I go to /bogus_file.txt
    Then I should see "File not found."
    When I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    When I go to /bogus_file.txt
    Then I should see "Some text in file."

  Scenario: User tries do download a bogus file and then upload difrent type of file
    When I create "/" page
    And I go to /bogus_still_file.txt
    Then I should see "File not found."
    When I attach the file at "picture.jpg" to "file_version_uploaded_data"
    And I press "Upload"
    Then I should see "Type of file not match."
    When I go to /bogus_still_file.txt
    Then I should see "File not found."

  Scenario: Anonymous user tries do download a bogus file
    Given I am not logged in
    And I go to /bogus_file.txt
    Then I should see "File not found."
    And I should not see "You can upload this file."

  Scenario: User tries do download a bogus file and then upload difrent type of file
    When I create "/" page
    And I create "/new_page/" page
    And I go to /new_page/link.txt
    Then I should see "File not found."
    When I attach the file at "picture.jpg" to "file_version_uploaded_data"
    And I press "Upload"
    Then I should see "Type of file not match."
    And I go to /new_page/link.txt
    Then I should see "File not found."

  Scenario: User tries do download a bogus file and then upload difrent name
    When I create "/" page
    And I create "/new_page/" page
    And I go to /new_page/link.txt
    Then I should see "File not found."
    When I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    And I go to /new_page/link.txt
    Then I should see "Some text in file."

  Scenario: User uploads some files and wants to see them all
    When I create "/" page
    And I follow "edit"
    And I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Save"
    Then I should see "Page successfully updated."
    When I follow "edit"
    And I attach the file at "test_file2.txt" to "file_version_uploaded_data"
    And I press "Save"
    Then I should see "Page successfully updated."
    When I follow "files"
    Then I should see "test_file.txt"
    And I should see "test_file2.txt"

  Scenario: User uploads no files and tries to view a listing
    When I create "/" page
    And I follow "Files"
    Then I should see "No files uploaded for this page"

  Scenario: User uploads some files and wants to see them without listing subdirectories
    When I create "/" page
    And I follow "Edit"
    And I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Save"
    And I create "/nested/" page
    And I follow "Edit"
    And I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Save"
    And I go to the main page
    When I follow "Files"
    Then I should see "test_file.txt"
    And I should not see "nested"


  Scenario: User tries to view files list without permissions
    Given I am not logged in
    When I go to the main page
    And I login as "bio"
    And I create "/" page
    And page "/" is editable by "bio"
    And I follow "edit"
    And I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Save"
    And I follow "files"
    Then I should see "test_file.txt"
    When I logout
    And I go to ;files
    Then I should see "Permission denied."
    When I go to the main page
    And I login as "crutch"
    And I go to ;files
    Then I should see "Permission denied."

  Scenario: User tries to reupload existing file
    Given I am not logged in
    And I login as "user"
    And I create "/" page
    And I go to /test_file2.txt
    Then I should see "File not found."
    When I attach the file at "test_file.txt" to "file_version_uploaded_data"
    And I press "Upload"
    And I go to /test_file2.txt
    Then I should see "Some text in file."
    When I go to the main page
    And I logout
    And I login as "bio"
    And I follow "edit"
    And I attach the file at "test_file2.txt" to "file_version_uploaded_data"
    And I press "Save"
    And I go to /test_file2.txt
    Then I should see "Different text in file."
    When I go to the main page
    And I follow "files"
    Then I should see "test_file2.txt"
    And I should see "bio"
    And I should not see "user"

  Scenario: User wants to upload file with no ext trough file page
    When I create "/" page
    And I follow "files"
    And I attach the file at "readme" to "file_version_uploaded_data"
    And I press "Upload"
    Then I should see "File was successfully uploaded."
    When I go to /readme
    Then I should see "Some text in file."


  Scenario: User wants to upload file with no ext and there is a page with the same name
    When I create "/" page
    And I create "/readme/" page with title "citaj ma"
    And I go to the main page
    And I follow "edit"
    And I attach the file at "readme" to "file_version_uploaded_data"
    And I press "Save"
    Then I should see "There is a page with the same name."
    When I go to /readme
    Then I should see "citaj ma"

  Scenario: User wants download file from non existing page
    When I create "/" page
    And I go to /a/nested/bogus_file.txt
    Then I should see "File not found."

  Scenario: Two different users upload 2 versions of the same file
    Given I am not logged in
    When I login as "user"
    And I create "/" page
    And I follow "edit"
    And I attach the file at "readme" to "file_version_uploaded_data"
    And I press "Save"
    Then I logout
    When I login as "bio"
    And I go to the main page
    And I follow "edit"
    And I attach the file at "version2/readme" to "file_version_uploaded_data"
    And I press "Save"
    Then I should see "File was successfully uploaded."
    When I follow "files"
    And I follow "show file's history"
    Then I should see "readme 1 user"
    And I should see "readme 2 bio"
    When I go to /readme?version=1
    Then I should see "Some text in file."
    When I go to /readme?version=2
    Then I should see "Readme here version 2."

  Scenario: Two files with same name on two different pages
    When I create "/" page
    And I follow "edit"
    And I attach the file at "readme" to "file_version_uploaded_data"
    And I press "Save"
    And I create "/nested/" page
    And I follow "edit"
    And I attach the file at "version2/readme" to "file_version_uploaded_data"
    And I press "Save"
    And I go to the main page
    And I go to /readme
    Then I should see "Some text in file."
    And I go to /nested/readme
    Then I should see "Readme here version 2."
  
  Scenario: User wants to download latest version of file
    When I create "/" page
    And I follow "edit"
    And I attach the file at "readme" to "file_version_uploaded_data"
    And I press "Save"
    And I go to the main page
    And I follow "edit"
    And I attach the file at "version2/readme" to "file_version_uploaded_data"
    And I press "Save"
    Then I should see "File was successfully uploaded."
    When I follow "files"
    Then I should see "readme"
    When I go to readme
    Then I should see "Readme here version 2."