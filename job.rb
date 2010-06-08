require 'rubygems'
require 'redis'
require 'fileutils'
require 'cgi'
require 'open-uri'

class Manager

	WAIT = 1
	def initialize
		@redis = Redis.new
	end

	def work(limit = 1)
		limit.times do 
			#get a job id from redis
			id = @redis.lpop "jobs"
			
			if id
				puts "Got a job id: " + id
				folder = id.split(/-/).last.slice(0,6)
				url = @redis.get "job:#{id}:url"
				cb = @redis.get "job:#{id}:cb"
				puts "Url = #{url}"
				puts "Callback = #{cb}"

				filename = "/shots/#{folder}/#{id}.png"
				full_filename = File.join("public", filename)
				FileUtils.mkdir_p(File.join("public", "shots", folder))
				
puts full_filename
puts "Current directory is " + FileUtils.pwd
				
				#execute
				print_screen(url, full_filename)

				if cb && cb.length > 0 && File.exists?(full_filename)
					params = [[:id, id], [:location , full_filename]].collect{|a| "#{a.first}=#{CGI::escape(a.last)}"}.join("&")
					fcb = cb =~ /\?/ ? (cb + "&" + params) : (cb + "?" + params)
					puts "The full call back is " + fcb
					open(fcb){|f| }
				end

			end
		end
	end

	def print_screen(url, filename)
		`xvfb-run --server-args="-screen 0, 1024x768x24" webkit2png.py -o #{filename} "#{url}" -w #{WAIT} -F javascript -F plugins`
	end
end

m = Manager.new
m.work
