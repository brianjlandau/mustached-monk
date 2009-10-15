class Main
  get "/" do
    @name = "world"
    mustache :hello, {}, {:title => 'Hello'}
  end
end
