#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] {email or id of the member to remove}"

parse_options()
    
if (ARGV.length < 1)
    puts
    puts "Please enter member's email or id. The member must already have a profile."
    puts
    puts $opts
    exit(1)
end

id = ARGV[0]
if (id.include? "@")
    $o.params[:email] = id
else
    $o.params[:id] = id
end

res = exec_api_call("remove-member")