require 'rubygems'
require 'redis'
require 'sinatra'
require 'json'

get "/schedule" do 
	url = params[:url]
	cb = params[:callback]

	#get a unique hash for this job
	ts = Time.now.to_i.to_s
	folder = ts.slice(0,6)
	id = Digest::MD5.hexdigest(url) + "-" + ts

	redis = Redis.new
	#set data for this schedule
	redis.set "job:#{id}:url" , url
	redis.set "job:#{id}:cb" , cb
	
	#now push to the job list
	redis.rpush "jobs", id

	{:url => url, :callback => cb, :jobid => id, :location => "/shots/#{folder}/#{id}.png"}.to_json
end

get "/echo" do 
	params.to_json
end
