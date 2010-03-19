Feature: Open Files via Drb
  In order to open Redcar faster.
  I want to be able to open files and directories in an already running instance.
  
  Scenario: It opens a file via drb
    Given I startup a remote instance
    Then I should not remotely see "Wintersmith" in the edit tab
    When I open "plugins/project/features/fixtures/winter.txt" from the command line
    Then there should be one edit tab
    And I should remotely see "Wintersmith" in the edit tab

# it should create new files

# it should ignore -x files

# it should focus on the existing tab if opened from the command line

# two should go to same tab

# if a dir is open which is the wrong dir, it should create new

# if a dir is open and a new dir is opened, it should create new

# if a dir is open and it is in that dir, should go to that dir