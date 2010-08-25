require 'rubygems'
require 'redis'
require 'fileutils'
require 'cgi'
require 'open-uri'
require 'digest'
require 'resque'
require 'json'
require 'timeout'

class Peep

  @queue = :peeping_tom

  def initialize(uid, url, options = {})
    @uid, @url = uid, url
    @folder = Peep.folder_from_uid(@uid)
    @options = {"wait" => 1}.merge(options)
    @filename = "/shots/#{@folder}/#{@uid}.png"
    @full_filename = File.join("public", @filename)
  end

  def work

    FileUtils.mkdir_p(File.join("public", "shots", @folder))

    print_screen(@url, @full_filename)

    raise if !File.exists?(@full_filename)

    cb = @options["callback"]
    if cb && cb.length > 0 && File.exists?(@full_filename)
      params = [[:id, @uid], [:location , @filename]].collect{|a| "#{a.first}=#{CGI::escape(a.last)}"}.join("&")
      fcb = cb =~ /\?/ ? (cb + "&" + params) : (cb + "?" + params)
      f = open(fcb); f.close
    end

  end

  def print_screen(url, filename)

     puts "Priting screen"
     extra = "-F javascript -F plugins"
     if @options["width"]
        extra << " --scale=#{@options["width"]} #{@options["height"]} --aspect-ratio=crop"
     end

     Timeout::timeout(30) do 
      `xvfb-run --server-args="-screen 0, 1024x768x24" webkit2png.py -o #{filename} -t 20 "#{url}" -w #{@options["wait"]} #{extra}`
     end

     puts "Done"

      rescue  Timeout::Error
      puts "Errored, killing and moving on"
       `killall Xvfb`
       `killall xvfb-run`
  end

  def self.uid(url)
    ts = Time.now.to_i.to_s
    Digest::MD5.hexdigest(url) + "-" + ts
  end

  def self.folder_from_uid(uid)
    uid.split(/-/).last.slice(0,6)
  end

  def self.perform(uid, url, options)
    Peep.new(uid, url, options).work
  end

  def self.queue_url(params)
    url = params[:url]

    #get a unique hash for this job
    uid = Peep.uid(url)
    folder = Peep.folder_from_uid(uid)

    Resque.enqueue Peep, uid, url, params.reject{|k,v| %w(url).include?(k.to_s)}
    {:url => url, :callback => params[:callback], :jobid => uid, :location => "/shots/#{folder}/#{uid}.png"}.to_json
  end
end
