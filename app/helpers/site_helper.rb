class Main
  module Helpers
    module Site
      # View helper methods can go here and then be included in your
      # mustache view files.
      
      def html_escape(s)
        s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
      end
      alias_method :h, :html_escape
      
      def help_me
        "HELP!"
      end
    end
  end
end
