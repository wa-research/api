#!/usr/bin/env ruby
require_relative 'cmd'

$opts.banner="Usage: #{File.basename($0)} [options]"

parse_options()
    
$o.fullBody = true

res = exec_api_call("list-threads")