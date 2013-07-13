#!/usr/bin/env ruby
require 'optparse'
require 'ostruct'
require 'net/http'
require 'pp'


class Hash 
    # File merb/core_ext/hash.rb, line 87
    def to_params
      params = ''
      stack = []

      each do |k, v|
        if v.is_a?(Hash)
          stack << [k,v]
        else
          params << "#{k}=#{v}&"
        end
      end

      stack.each do |parent, hash|
        hash.each do |k, v|
          if v.is_a?(Hash)
            stack << ["#{parent}[#{k}]", v]
          else
            params << "#{parent}[#{k}]=#{v}&"
          end
        end
      end

      params.chop! # trailing &
      params
    end
end

class ECSApi
    attr_accessor :options

    def initialize
        @options = self.read_options
    end
    
    def gettime(options)
        time = localtime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
        if (options.sync_time)
            url = URI.parse(options.server)
            begin
                Net::HTTP.start(url.host, url.port, :use_ssl => url.class == URI::HTTPS, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
                    req = Net::HTTP::Get.new('/api.axd?operation=time')
                    response = http.request(req)
                    time = response.body if response.code == '200'
                    #re-do local time as the request might have taken a few seconds
                    localtime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
                end
            rescue Exception => e
                $stderr.puts "ERROR: Could not synchronize time. Is URL #{url} accessible? Using local time: #{time}"
            end
        end
        time
    end

    def sign(operation, options)
        time = gettime(options)
        require "digest/sha1"
        # operation site-id password request-time, example: adduser wa 1 time
        sig = Digest::SHA1.hexdigest("#{operation}#{options.user}#{options.key}#{time}")
        return time, sig
    end

    def apiurl(operation, options, parms = {})
        time, sig = sign(operation, options)
        qoramp = options.url.include?("?") ? "&" : "?"
        apiurl = "#{options.server}/#{options.url}#{qoramp}operation=#{operation}&site-id=#{options.user}&request-time=#{time}&signature=#{sig}"
        parms["verbose"] = true if options.verbose
        apiurl = apiurl + "&" + parms.to_params
        return apiurl
    end
    
    def read_options

        o = OpenStruct.new
        o.user = 'wa-test'
        o.key = '1'
        o.url = 'api.axd'
        o.server = 'http://vs.local'
        o.sync_time = true

        OptionParser.new do |opts|
            opts.banner = "Usage: #{File.basename($0)} [options] operation"
            opts.on('-u', '--user USER', 'Api username USER', " (#{o.user})") do |user|
                o.user = user
            end
            opts.on('-k', '--key KEY', 'Use the api key KEY',  " (#{o.key})") do |key|
                o.key = key
            end
            opts.on('-s','--server SERVER', 'Access the API from server http://SERVER', " (#{o.server})") do |server|
                o.server = server
            end
            opts.on('-u','--url URL', 'Sign the url /URL', " (#{o.url})") do |url|
                o.url = url
            end
            opts.on('--[no-]sync-time', 'Synchronize with server time', " (#{o.sync_time})") do |sync|
                o.sync_time = sync
            end
            opts.on('-v', '--verbose', "Show verbose output", " (#{o.verbose})") do |v|
                o.verbose = v
            end
            opts.on('-d', '--debug', "Show debug output from http request", " (#{o.debug})") do |d|
                o.debug = d
            end
            opts.on('-h', '--help', 'Display this help') do
                puts opts
                exit
            end
        end.parse!
        
        return o
    end

end

if __FILE__==$0
    if (ARGV.length < 1)
        puts "Please enter API operation you want to sign"
        exit
    end

    operation = ARGV[0]

    api = ECSApi.new
    o = api.options
    
    p o if o.verbose
    puts 

    u = api.apiurl(operation, o)
    pp u if o.verbose
    url = URI.parse(u)

    #res = Net::HTTP.get_response(url)         

    Net::HTTP.start(url.host, url.port, :use_ssl => url.class == URI::HTTPS, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        res = http.request(req)
        case res
            when Net::HTTPRedirection
                puts "Redirected to #{res['location']}"
            when Net::HTTPSuccess
                puts res.body
            else
                puts res.error!
        end
    end    

    pp res.body
end