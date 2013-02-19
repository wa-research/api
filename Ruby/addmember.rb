#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] member's_email_address or id"

$opts.separator ""
$opts.separator "Operation-specific parameters:"
$opts.separator ""

$opts.on('--role ROLE', "The role must be either Member or Leader", "Default member") do |v|
    $o.params[:role] = v
end

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

res = exec_api_call("add-member")
