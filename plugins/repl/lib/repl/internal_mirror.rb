
module Redcar
  class REPL
    class InternalMirror
      include Redcar::Document::Mirror
      
      POINTERS = {
        :output => "",
        :result => "=> ",
        :error  => "x> "
      }
      
      attr_reader :history, :results
      
      def initialize
        @history, @instance = [], Main.new
      end

      def title
        "(internal)"
      end
      
      # Get the complete history of commands and results as a pretty formatted
      # string.
      #
      # @return [String]
      def read
        str = message
        
        @history.each do |entry|
          command = entry.first
          results = entry.last
          str << prompt.to_s + command.to_s + "\n"
          results.each do |result|
            output, entry_type = *result
            str << POINTERS[entry_type]
            output.scan(/.{1,80}/).each do |output_line|
              str << output_line + "\n"
            end
          end
        end
        str << prompt
        if @history.length > 0
          puts 'adding', @history.inspect, @history[-1].inspect, 'really', @history[-1].first
          str << @history[-1].first
        end
        str
      end

      # Execute a new statement. Accepts the entire pretty formatted history,
      # within which it looks for the last statement and executes it.
      #
      # @param [String] a string with at least one prompt and statement in it
      def commit(contents)
        if contents.split("\n").last =~ />>\s+$/
          command = ""
        else
          command = contents.split(prompt).last
        end
        @history << [command, []]
        begin
          result, entry_type = @instance.execute(command).inspect, :result
        rescue Object => e
          result, entry_type = format_error(e), :error
        end
        @history.last[1] << [@instance.output, :output] if @instance.output
        @history.last[1] << [result, entry_type]
        notify_listeners(:change)
      end

      # The Repl always exists because there is no external resource to 
      # represent.
      def exists?
        true
      end

      # The Repl never changes except for after commit operations.
      def changed?
        false
      end

      private
      
      def message
        "# Redcar REPL\n\n"
      end
      
      def prompt
        ">> "
      end
      
      def format_error(e)
        backtrace = e.backtrace.reject{|l| l =~ /internal_mirror/}
        backtrace.unshift("(repl):1")
        "#{e.class}: #{e.message}\n        #{backtrace.join("\n        ")}"
      end
      
      class Main
        attr_reader :output
        
        def initialize
          @binding = binding
          @output = nil
        end

        def inspect
          "main"
        end
        
        def execute(command)
          orig_stdout = $stdout
          stdout_handler = StringIO.new
          $stdout = stdout_handler
          begin
            result = eval(command, @binding)
          ensure
            $stdout.rewind
            @output = $stdout.read
            $stdout = orig_stdout
          end
          result
        end
      end
    end
  end
end
