#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] { community_name }"

$opts.separator ""
$opts.separator "Operation-specific parameters:"
$opts.separator ""

$opts.on('--email EMAIL', "Email address") do |v|
    $o.params[:email] = v
end
$opts.on('--displayName DISPLAYNAME', "Pretty name") do |v|
    $o.params[:displayname] = v
end
$opts.on('--leader EMAIL', "Leader's email address") do |v|
    $o.params[:leader] = v
end

parse_options()
    
if (ARGV.length < 1)
    puts
    puts "Please enter the communtiy name."
    puts
    puts $opts
    exit(1)
end

$o.params[:name] = ARGV[0]

res = exec_api_call("create-community")
