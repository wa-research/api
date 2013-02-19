#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] {id of a member profile to update}"

$opts.separator ""
$opts.separator "Operation-specific parameters:"
$opts.separator ""

$opts.on('--email EMAIL', "Email") do |v|
    $o.params[:email] = v
end
$opts.on('--first FIRST', "First name") do |v|
    $o.params[:lastName] = v
end
$opts.on('--last LAST', 'Last name') do |v|
    $o.params[:firstName] = v
end
$opts.on('--country COUNTRY', "User's country") do |v|
    $o.params[:country] = v
end
$opts.on('--organization ORGANIZATION') do |v|
    $o.params[:organization] = v
end
$opts.on('--position POSITION') do |v|
    $o.params[:position] = v
end
$opts.on('--tel TEL') do |v|
    $o.params[:tel] = v
end
$opts.on('--password PASSWORD') do |v|
    $o.params[:password] = v
end
$opts.on('--role ROLE', "The role must be either Member or Leader", "Default member") do |v|
    $o.params[:role] = v
end

parse_options()
    
if (ARGV.length < 1)
    puts
    puts "Please enter member's id."
    puts
    puts $opts
    exit(1)
end

$o.params[:id] = ARGV[0]

res = exec_api_call("update-user-profile")
