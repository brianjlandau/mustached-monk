class Main
  module Views
    class Hello < Mustache
      attr_reader :name
      
      def link_to_homepage
        link "HomePage", '/'
      end
    end
  end
end
