require "sinatra"

configure do
  set :server, :puma
end

get "/" do
  "hello cloud-run\n"
end

# SINATRA_SOURCE: cloud-run-app
