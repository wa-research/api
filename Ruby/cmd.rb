#!/usr/bin/env ruby
require 'optparse'
require 'ostruct'
require 'net/http'
require 'pp'
require_relative 'ecsapi'

# Defaults
$o = OpenStruct.new
$o.url = '__api/v1/'
$o.sync_time = true
$o.verbose = false
$o.debug = false
$o.params = {}

$opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} [options] operation"
    opts.separator ""
    opts.separator "API parameters and options:"
    opts.separator ""
    
    opts.on('-c','--community COMMUNITY', 'Absolute URL of the community in the form http://server/community_parent/community_name',) do |community|
        community += '/' if (community[community.length-1] != '/')
        $o.server = community
    end
    opts.on('-u', '--user USER', 'Api username USER') do |user|
        $o.user = user
    end
    opts.on('-k', '--key KEY', 'Use the api key KEY',) do |key|
        $o.key = key
    end
    opts.on('--apipath APIPATH', " (#{$o.url})") do |url|
        url += '/' if (url[url.length-1] != '/')
        $o.url = url
    end
    opts.on('--[no-]sync-time', 'Synchronize with server time', "  Default: #{$o.sync_time}") do |sync|
        $o.sync_time = sync
    end
    opts.on('-v', '--verbose', "Show verbose output", "  Default: #{$o.verbose}") do |v|
        $o.verbose = v
    end
    opts.on('-d', '--debug', "Show debug output from http request", "  Default: #{$o.debug}") do |d|
        $o.debug = d
    end
    opts.on('--full-body', "Print full body output (otherwise print only 150 chars of result)") do |b|
        $o.fullBody = b
    end
    opts.on('-p', '--params PARAMS', "Additional api parameters, in name=value,name=value,... format") do |p|
        $o.params = Hash[*p.split(/=|,/)]
    end
    opts.separator ""
    opts.on('-h', '--help', 'Display this help') do
        puts opts
        exit
    end
end

def parse_options(mandatory = [:url, :server])
    begin
        $opts.parse!
        missing = mandatory.select{ |param| $o.send(param).nil? }
        if not missing.empty?
            puts
            puts "Missing: #{missing.join(', ')}"
            puts
            puts $opts
            exit(1)
        end
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts
        puts $!.to_s
        puts
        puts $opts
        exit(1)
    end
end

def exec_api_call(operation)
    p $o if $o.verbose
    puts 

    api = ECSApi.new
    time, sig = api.sign(operation, $o)
    url = URI.join($o.server, $o.url, operation)
    
    #pp url,time,sig if $o.verbose

    $o.params['site-id'] = $o.user
    $o.params['signature'] = sig
    $o.params['request-time'] = time
    
    res = nil
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data $o.params
    
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
    
    if ($o.verbose)
        puts
        puts res.code
        res.header.each_header {|key,value| puts "#{key} = #{value}" }
        puts
    end
    res
end

if __FILE__==$0

    parse_options()

    if (ARGV.length < 1)
        puts
        puts "\nPlease enter API operation you want to sign"
        puts
        puts $opts
        exit(1)
    end
    
    res = exec_api_call(ARGV[0])

    if ($o.fullBody)
        puts res.body
    else
        puts res.body[0..150]
    end
end