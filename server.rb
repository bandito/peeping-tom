require 'rubygems'
require 'sinatra'
require 'peep'

set :public, File.dirname(__FILE__) + '/public'

get "/schedule" do
  Peep.queue_url(params)
end

get "/echo" do 
  params.to_json
end

