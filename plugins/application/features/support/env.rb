module SwtHelper
  def main_menu
    display = Redcar::ApplicationSWT.display
    shell   = display.get_shells.to_a.first
    menu_bar = shell.get_menu_bar
    menu_bar
  end
  
  def first_shell
    Redcar::ApplicationSWT.display.get_shells.to_a.first
  end
  
  def active_shell
    Redcar::ApplicationSWT.display.get_active_shell
  end
  
  def dialog(type)
    dialogs.detect {|d| d.is_a?(type) }
  end
  
  def dialogs
    Redcar::ApplicationSWT.display.get_shells.to_a.map do |s| 
      Redcar::ApplicationSWT.shell_dialogs[s]
    end.compact
  end
  
  def sash_form 
    active_shell.getChildren.to_a.first
  end
  
  def tree_book
    sash_form.getChildren.to_a.first
  end
  
  def top_tree
    r = tree_book.getLayout.topControl
    r.extend(TreeHelpers)
    r
  end
  
  module TreeHelpers
    def items
      getItems.to_a
    end
    
    def item_texts
      getItems.to_a.map {|item| item.getText}
    end
  end
end
    
class FakeDialogAdapter
  def initialize
    @responses = {}
  end
  
  def set(method, value)
    @responses[method] = value
  end
  
  def open_file(*args)
    check_for_raise(@responses[:open_file])
  end
  
  def open_directory(*args)
    check_for_raise(@responses[:open_directory])
  end
  
  def save_file(*args)
    check_for_raise(@responses[:save_file])
  end
  
  def message_box(*args)
    check_for_raise(@responses[:message_box].to_sym)
  end
  
  def check_for_raise(result)
    if result == :raise_error
      raise "did not expect dialog"
    end
    result
  end
  
  def available_message_box_button_combos
    Redcar::ApplicationSWT::DialogAdapter.new.available_message_box_button_combos
  end
end

World(SwtHelper)

def close_everything
  Redcar::ApplicationSWT.sync_exec do
    dialogs.each {|d| d.controller.model.close }
  end
  Redcar.app.windows.each do |win|
    while tree = win.treebook.trees.first
      Redcar::ApplicationSWT.sync_exec do
        win.treebook.remove_tree(tree)
      end
    end
    win.notebooks.each do |notebook|
      while tab = notebook.tabs.first
        Redcar::ApplicationSWT.sync_exec do
          tab.close
        end
      end
    end
    if win.notebooks.length == 2
      Redcar::ApplicationSWT.sync_exec do
        win.close_notebook
      end
    end
  end
  while Redcar.app.windows.length > 1
    Redcar::ApplicationSWT.sync_exec do
      Redcar.app.windows.last.close
    end
  end
  Redcar::ApplicationSWT.sync_exec do
    Redcar.app.windows.first.title = Redcar::Window::DEFAULT_TITLE
  end
end

Before do
  close_everything
  Redcar::ApplicationSWT::FilterListDialogController.test_mode = true
end

After do
  close_everything
end
