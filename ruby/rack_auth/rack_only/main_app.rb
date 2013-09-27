module Rask
  class MainApp
    def call(env)
      $stdout.puts "@main_app"
      [200, {'Content-Type'=> 'text/html'}, ["Hola"]]
    end
  end
end
