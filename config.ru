require 'server'

Sinatra::Application.set :run, false
Sinatra::Application.set :env, ENV['RACK_ENV'] || 'development'

run Sinatra::Application
