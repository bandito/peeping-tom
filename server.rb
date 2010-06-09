require 'rubygems'
require 'sinatra'
require 'peep'

get "/schedule" do
  Peep.queue_url(params)
end

get "/echo" do 
  params.to_json
end

