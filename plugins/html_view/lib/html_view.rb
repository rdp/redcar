
require 'html_view/html_tab'

module Redcar
  class HtmlView
    attr_reader :controller
  
    def initialize(html_tab)
      @html_tab = html_tab
    end
    
    def controller=(new_controller)
      @controller = new_controller
      @html_tab.title = controller.title
      func = RubyFunc.new(@html_tab.controller.browser, "rubyCall")
      func.controller = @controller
      text = controller.index + setup_javascript_listeners
      @html_tab.controller.browser.set_text(text)
    end
    
    def contents=(source)
      @html_tab.controller.browser.set_text(source)
    end
    
    private
    
    class RubyFunc < Swt::Browser::BrowserFunction
      def function(args)
        func_name = args.to_a.first
        func_args = args.to_a.last.to_a
        controller.send(func_name.to_sym, *func_args)
      end
      
      attr_accessor :controller
    end
        
    def setup_javascript_listeners
      js = []
      js << "<script type=\"text/javascript\">"
      js << "Controller = {"
      methods = []
      (controller.methods - Object.new.methods).each do |method_name|
        method = []
        method << "  #{method_name.gsub(/_(\w)/) { |a| $1.upcase}}: function() {"
        method << "    rubyCall(\"#{method_name}\", Array.prototype.slice.call(arguments));"
        method << "  }"
        methods << method.join("\n")
      end
      js << methods.join(",\n")
      js << "};"
      js << "</script>"
      js.join("\n")
    end
  end
end
