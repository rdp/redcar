module Redcar
  class CTags
    class CompletionSource
      def initialize(_, project_path)
        @project_path = project_path
      end
      
      def alternatives(prefix)
        if @project_path
          word_list = AutoCompleter::WordList.new
          tags = CTags.tags_for_path(CTags.file_path(@project_path))
          tags.keys.each do |tag| 
            if tag[0..(prefix.length-1)] == prefix
              word_list.add_word(tag, 10000)
            end
          end
          word_list
        end
      end
    end
  end
end