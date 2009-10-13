class Main
  module Views
    class Hello < Mustache
      include Main::Helpers::Site
      
      attr_reader :name
    end
  end
end
