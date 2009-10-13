class Main
  get "/" do
    @name = "world"
    mustache :hello
  end
end
