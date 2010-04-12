
module NotebookSwtHelper
  def sash
    sash = active_shell.children.to_a.first
  end
  
  def ctab_folders
    sash.children.to_a[1].children.to_a[0].children.to_a.select do |c| 
      c.class == Java::OrgEclipseSwtCustom::CTabFolder
    end
  end
end

World(NotebookSwtHelper)

When /^I make a new notebook$/ do
  Redcar::Top::NewNotebookCommand.new.run
end

When /^I move the tab to the other notebook$/ do
  Redcar::Top::MoveTabToOtherNotebookCommand.new.run
end

When /^I close the current notebook$/ do
  Redcar::Top::CloseNotebookCommand.new.run
end

When /^I switch notebooks$/ do
  Redcar::Top::SwitchNotebookCommand.new.run
end

When /^I focus on the edit_view in the tab in notebook (\d)$/ do |index|
  index = index.to_i - 1
  notebook = Redcar.app.windows.first.notebooks[index]
  edit_view = notebook.focussed_tab.edit_view
  edit_view.controller.swt_focus_gained
end

Then /^there should be (one|two) notebooks?$/ do |count_str|
  count = count_str == "one" ? 1 : 2
  # in the model
  Redcar.app.windows.first.notebooks.length.should == count
  
  # in the GUI
  ctab_folders.length.should == count
end


Then /^notebook (\d) should have (\d) tabs?$/ do |index, tab_count|
  index = index.to_i - 1
  # in the model
  Redcar.app.windows.first.notebooks[index].tabs.length.should == tab_count.to_i
  
  # in the GUI
  ctab_folders[index].children.to_a.length.should == tab_count.to_i
end

Then /^the tab in notebook (\d) should contain "([^\"]*)"$/ do |index, str|
  index = index.to_i - 1
  # in the model
  tab = Redcar.app.windows.first.notebooks[index].focussed_tab
  tab.edit_view.document.to_s.include?(str).should be_true
end

