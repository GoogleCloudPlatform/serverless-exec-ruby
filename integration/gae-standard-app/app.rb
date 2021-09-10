require "sinatra"

configure do
  set :server, :puma
end

get "/" do
  "hello gae-standard\n"
end

# SINATRA_SOURCE: gae-standard-app
