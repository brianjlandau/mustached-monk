class Main
  module Helpers
    module Site
      # View helper methods can go here and then be included in your
      # mustache view files.
      
      def html_escape(text)
        Rack::Utils.escape_html(text)
      end
      alias_method :h, :html_escape
      alias_method :escape_html, :html_escape
      
      def help_me
        "HELP!"
      end
    end
  end
end
