require 'rubygems'
require 'redis'
require 'fileutils'
require 'cgi'
require 'open-uri'
require 'digest'
require 'resque'
require 'json'

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
    cb = @options["callback"]
    if cb && cb.length > 0 && File.exists?(@full_filename)
      params = [[:id, @uid], [:location , @full_filename]].collect{|a| "#{a.first}=#{CGI::escape(a.last)}"}.join("&")
      fcb = cb =~ /\?/ ? (cb + "&" + params) : (cb + "?" + params)
      f = open(fcb); f.close
    end

  end

  def print_screen(url, filename)
    `xvfb-run --server-args="-screen 0, 1024x768x24" webkit2png.py -o #{filename} "#{url}" -w #{@options["wait"]} -F javascript -F plugins`
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
    cb = params[:callback]

    #get a unique hash for this job
    uid = Peep.uid(url)
    folder = Peep.folder_from_uid(uid)

    Resque.enqueue Peep, uid, url, {:callback => cb}
    {:url => url, :callback => cb, :jobid => uid, :location => "/shots/#{folder}/#{uid}.png"}.to_json
  end
end
