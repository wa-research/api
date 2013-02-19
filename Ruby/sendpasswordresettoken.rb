#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] {email address to send the token to}"

parse_options()
    
if (ARGV.length < 1)
    puts
    puts "Please enter user email address."
    puts
    puts $opts
    exit(1)
end

$o.params[:email] = ARGV[0]

res = exec_api_call("reset-password")