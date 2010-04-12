
module Redcar
  class Project
    class Manager
    
      def self.open_projects
        Project.window_projects.values
      end
      
      def self.in_window(window)
        Project.window_projects[window]
      end
      
      # this will restore open files unless other files or dirs were passed
      # as command line parameters
      def self.start
        restore_last_session unless handle_startup_arguments
        init_current_files_hooks
        init_window_closed_hooks
        init_drb_listener
      end
      
      def self.init_window_closed_hooks
        Redcar.app.add_listener(:window_about_to_close) do |win|
          project = in_window(win)
          project.close if project
          self.save_file_list(win)
        end
      end
      
      def self.init_drb_listener
        return if ARGV.include?("--multiple-instance")
        @drb_service = DrbService.new
      end
      
      def self.storage
        @storage ||= Plugin::Storage.new('project_plugin')
      end
      
      def self.filter_path
        if Redcar.app.focussed_notebook_tab
          if mirror = EditView.focussed_document_mirror and mirror.is_a?(FileMirror)
            dir = File.dirname(mirror.path)
            return dir
          end
        end      
        storage['last_dir'] || File.expand_path(Dir.pwd)
      end
    
      def self.sensitivities
        [ @open_project_sensitivity = 
            Sensitivity.new(:open_project, Redcar.app, false, [:focussed_window]) do
              if win = Redcar.app.focussed_window
                win.treebook.trees.detect {|t| t.tree_mirror.is_a?(DirMirror) }
              end
            end
        ]
      end
      
      # Finds an EditTab with a mirror for the given path.
      #
      # @param [String] path  the path of the file being edited
      # @return [EditTab, nil] the EditTab that is editing it, or nil
      def self.find_open_file_tab(path)
        path = File.expand_path(path)
        all_tabs = Redcar.app.windows.map {|win| win.notebooks}.flatten.map {|nb| nb.tabs }.flatten
        all_tabs.find do |t| 
          t.is_a?(Redcar::EditTab) and 
          t.edit_view.document.mirror and 
          t.edit_view.document.mirror.is_a?(FileMirror) and 
          File.expand_path(t.edit_view.document.mirror.path) == path 
        end
      end
      
      # Opens a new EditTab with a FileMirror for the given path.
      #
      # @path  [String] path the path of the file to be edited
      # @param [Window] win  the Window to open the File in
      def self.open_file_in_window(path, win)
        tab = win.new_tab(Redcar::EditTab)
        mirror = FileMirror.new(path)
        tab.edit_view.document.mirror = mirror
        tab.edit_view.reset_undo
        tab.focus
      end
      
      def self.find_project_containing_path(path)
        open_projects.detect {|project| project.contains_path?(path) }
      end
      
      def self.open_file(path)
        if tab = find_open_file_tab(path)
          tab.focus
          return
        end
        if project = find_project_containing_path(path)
          window = project.window
        else
          window = Redcar.app.focussed_window || Redcar.app.new_window
        end
        open_file_in_window(path, window)
        window.focus
      end
      
      # Opens a new Tree with a DirMirror and DirController for the given
      # path, in a new window.
      #
      # @param [String] path  the path of the directory to view
      def self.open_project_for_path(path)
        win     = Redcar.app.new_window
        project = Project.new(path)
        project.open(win)
      end
      
      # The currently focussed Project, or nil if none.
      #
      # @return [Project]
      def self.focussed_project
        in_window(Redcar.app.focussed_window)
      end
      
      # saves away a list of the currently open files in
      # @param [win]
      def self.save_file_list(win)
        # create a list of open files
        file_list = []
        win.notebooks[0].tabs.each do |tab|
          if tab.document && tab.document.path
            file_list << tab.document.path
          end
        end
        storage['files_open_last_session'] = file_list      
      end
      
      # handles files and/or dirs passed as command line arguments
      def self.handle_startup_arguments
        found_path_args = false
        ARGV.each do |arg|
          if File.directory?(arg)
            found_path_args = true
            open_project_for_path(arg)
          elsif File.file?(arg)
            found_path_args = true
            open_file(arg)
          end
        end
        found_path_args
      end
      
      # Attaches a new listener to tab focus change events, so we can 
      # keep the current_files list.
      def self.init_current_files_hooks
        Redcar.app.add_listener(:tab_focussed) do |tab|
          if tab and tab.document_mirror.respond_to?(:path)
            if project = Manager.in_window(tab.notebook.window)
              project.add_to_recent_files(tab.document_mirror.path)
            end
          end
        end
        attach_app_listeners
      end
      
      def self.attach_app_listeners
        Redcar.app.add_listener(:lost_focus) do
          FindFileDialog.clear
        end
        
        Redcar.app.add_listener(:focussed) do
          Manager.open_projects.each {|project| project.refresh }
        end
      end
      
      # restores the directory/files in the last open window
      def self.restore_last_session
        if path = storage['last_open_dir']
          s = Time.now
          open_project_for_path(path)
          puts "open project took #{Time.now - s}s"
        end
        
        if files = storage['files_open_last_session']
          files.each do |path|
            open_file(path)
          end
        end
      end
          
      class << self
        attr_reader :open_project_sensitivity
      end
    end
  end
end