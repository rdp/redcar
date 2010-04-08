Feature: Find file

  Background:
    Given I will choose "plugins/project/spec/fixtures/myproject" from the "open_directory" dialog
    When I open a directory

  Scenario: No files initially and with nothing typed
    When I run the command Redcar::Project::FindFileCommand
    Then there should be a filter dialog open
    And the filter dialog should have no entries
    
  Scenario: No matching files
    When I run the command Redcar::Project::FindFileCommand
    And I set the filter to "xxx"
    And I wait "0.4" seconds
    Then the filter dialog should have 0 entries
    
  Scenario: One matching file
    When I run the command Redcar::Project::FindFileCommand
    And I set the filter to "foo_spec"
    And I wait "0.4" seconds
    Then the filter dialog should have 1 entry
    And I should see "foo_spec.rb (myproject/spec)" at 0 the filter dialog

  Scenario: Two matching files
    When I run the command Redcar::Project::FindFileCommand
    And I set the filter to "foo"
    And I wait "0.4" seconds
    Then the filter dialog should have 2 entries
    And I should see "foo_lib.rb (myproject/lib)" at 0 the filter dialog
    And I should see "foo_spec.rb (myproject/spec)" at 1 the filter dialog
    
  Scenario: One matching file with arbitrary letters
    When I run the command Redcar::Project::FindFileCommand
    And I set the filter to "fsc"
    And I wait "0.4" seconds
    Then the filter dialog should have 1 entry
    And I should see "foo_spec.rb (myproject/spec)" at 0 the filter dialog

  Scenario: Open a file
    When I run the command Redcar::Project::FindFileCommand
    And I set the filter to "fsc"
    And I wait "0.4" seconds
    And I select in the filter dialog
    Then there should be no filter dialog open
    And I should see "foo spec" in the edit tab

  Scenario: Open a file then see the file in the initial list
    When I run the command Redcar::Project::FindFileCommand
    And I set the filter to "fsc"
    And I wait "0.4" seconds
    And I select in the filter dialog
    And I run the command Redcar::Project::FindFileCommand
    Then the filter dialog should have 1 entry
    And I should see "foo_spec.rb (myproject/spec)" at 0 the filter dialog

  Scenario: Open two files then see the files in the initial list
    When I have opened "plugins/project/spec/fixtures/myproject/spec/foo_spec.rb"
    And I have opened "plugins/project/spec/fixtures/myproject/lib/foo_lib.rb"
    And I run the command Redcar::Project::FindFileCommand
    Then the filter dialog should have 2 entries
    And I should see "foo_spec.rb (myproject/spec)" at 0 the filter dialog
    And I should see "foo_lib.rb (myproject/lib)" at 1 the filter dialog

  Scenario: Open three files then see the files in the initial list
    When I have opened "plugins/project/spec/fixtures/myproject/spec/foo_spec.rb"
    And I have opened "plugins/project/spec/fixtures/myproject/lib/foo_lib.rb"
    And I have opened "plugins/project/spec/fixtures/myproject/README"
    And I run the command Redcar::Project::FindFileCommand
    Then the filter dialog should have 3 entries
    And I should see "foo_lib.rb (myproject/lib)" at 0 the filter dialog
    And I should see "foo_spec.rb (myproject/spec)" at 1 the filter dialog
    And I should see "README (fixtures/myproject)" at 2 the filter dialog


