require "sinatra"

configure do
  set :server, :puma
end

get "/" do
  "hello gae-flexible\n"
end

# SINATRA_SOURCE: gae-flexible-app
