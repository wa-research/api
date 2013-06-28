#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options] subject text"

$opts.separator ""
$opts.separator "Operation-specific parameters:"
$opts.separator ""

$opts.on('--creatorEmail EMAIL', "Message creator's email address") do |v|
    $o.params[:creatoremail] = v
end
$opts.on('--creatorDisplayName DISPLAYNAME', "Message creator's display name") do |v|
    $o.params[:creatordisplayname] = v
end
$opts.on('--replyTo REPLYTO', "MessageID of the replied-to message") do |v|
    $o.params[:replyto] = v
end
$opts.on('--thread THREAD', "Thread ID the message should be associated with. Empty to start new thread") do |v|
    $o.params[:threadid] = v
end
$opts.on('--createdOn DATE', "Date the message was created on, in ISO format") do |v|
    $o.params[:createdon] = v
end


parse_options()
    
if (ARGV.length < 2)
    puts
    puts "Please enter the subject and text."
    puts
    puts $opts
    exit(1)
end

$o.params[:subject] = ARGV[0]
$o.params[:text] = ARGV[1]

res = exec_api_call("import-message")
