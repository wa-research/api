#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] {id of the user profile to delete}"

parse_options()
    
if (ARGV.length < 1)
    puts
    puts "Please enter user profile id. The member must already have a profile."
    puts
    puts $opts
    exit(1)
end

$o.params[:id] = ARGV[0]

res = exec_api_call("delete-user-profile")