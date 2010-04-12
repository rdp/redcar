module Redcar
  class Project
    class DrbService
      def initialize
        begin
          port = DRB_PORT
          ARGV.each{|arg| port = $1.to_i if arg =~ /^--port=(\d+)$/}
          address = "druby://127.0.0.1:#{port}"
          @drb = DRb.start_service(address, self)
        rescue Errno::EADDRINUSE => e
          puts 'warning--not starting listener (perhaps theres another Redcar already open?)' + e + ' ' + address
        end
      end
      
      def shutdown
        Redcar.app.quit
      end
      
      def examine_internals_drb
            all = {}
            all['windows'] = Redcar.app.windows.map{|w|
              windows = {}
              windows['trees'] = w.treebook.trees.collect{|tree| 
               tree.tree_mirror.respond_to?(:path) ? tree.tree_mirror.path : nil
              }.compact
              windows['notebooks'] = w.notebooks.map{|nb|
                notebooks = {}
                notebooks['tabs'] = nb.tabs.map{|t| 
                    t.document.path 
                }.compact
                notebooks['focussed'] = true if w.focussed_notebook == nb
                notebooks
              }
              windows['focussed'] = true if Redcar.app.focussed_window == w
              # focussed window--which?
              # focussed notebook within each window
              # focussed tab within each notebook
              windows 
            }
            all
      end
    
      def open_item_drb(full_path)
        begin
          puts 'drb opening ' + full_path if $VERBOSE
          if File.directory? full_path
            Redcar::ApplicationSWT.sync_exec do
              if Redcar.app.windows.length == 0 and Application.storage['last_open_dir'] == full_path
                Project::Manager.restore_last_session
              end
              
              if Redcar.app.windows.length > 0
                window = Redcar.app.windows.find do |win| 
                  next unless win
                  win.treebook.trees.find do |t| 
                    t.tree_mirror.is_a?(Redcar::Project::DirMirror) and t.tree_mirror.path == full_path
                  end
                end        
              end
              Project::Manager.open_project_for_path(full_path)
              Redcar.app.focussed_window.controller.bring_to_front
            end
            'ok'
          elsif full_path == 'just_bring_to_front'          
            Redcar::ApplicationSWT.sync_exec do
              if Redcar.app.windows.length == 0
                Project::Manager.restore_last_session
              end
              Redcar.app.focussed_window.controller.bring_to_front
            end
            'ok'
          elsif File.file?(full_path)
            Redcar::ApplicationSWT.sync_exec do
              if Redcar.app.windows.length == 0
                Project::Manager.restore_last_session
              end
              Project::Manager.open_file(full_path)
              Redcar.app.focussed_window.controller.bring_to_front
            end
            'ok'            
          end
        rescue Exception => e
          puts 'drb got exception:' + e.class + " " + e.message, e.backtrace
          raise e
        end 
      end
      
    end
  end
end
