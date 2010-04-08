module Redcar
  class AutoCompleter
    class DocumentController
      include Redcar::Document::Controller
      include Redcar::Document::Controller::ModificationCallbacks
      
      def start_completion
        @in_completion = true
      end
      
      def end_completion
        @in_completion = false
      end
      
      def in_completion?
        @in_completion
      end
      
      def start_modification
        @in_modification = true
      end
      
      def end_modification
        @in_modification = false
      end
      
      def in_modification?
        @in_modification
      end
      
      attr_accessor :index
      attr_accessor :length_of_previous
      attr_accessor :word_list, :prefix, :left, :right
      
      def before_modify(*_)
      end
      
      def after_modify(*_)
        unless in_modification?
          @in_completion = false
          @index         = 0
          @length_of_previous = nil
          @word_list = nil
          @prefix = nil
          @left = nil
          @right = nil
        end
      end
      
    end
  end
end
