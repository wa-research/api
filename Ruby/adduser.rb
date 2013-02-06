#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] users_email_address"

$opts.separator ""
$opts.separator "Operation-specific parameters:"
$opts.separator ""

$opts.on('--first FIRST', "First name") do |v|
    $o.lastName = v
end
$opts.on('--last LAST', 'Last name') do |v|
    $o.firstName = v
end
$opts.on('--country COUNTRY', "User's country") do |v|
    $o.country = v
end
$opts.on('--organization ORGANIZATION') do |v|
    $o.organization = v
end
$opts.on('--position POSITION') do |v|
    $o.position = v
end
$opts.on('--tel TEL') do |v|
    $o.tel = v
end
$opts.on('--password PASSWORD') do |v|
    $o.password = v
end
$opts.on('--role ROLE', "The role must be either Member or Leader", "Default member") do |v|
    $o.role = v
end

parse_options([:country])
    
if (ARGV.length < 1)
    puts
    puts "Please enter user's email"
    puts
    puts $opts
    exit(1)
end

$o.email = ARGV[0]

res = exec_api_call("adduser")
pp res.body[0 .. 150]
