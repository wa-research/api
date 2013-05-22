#!/usr/bin/env ruby
require 'net/http'

parms = { :email => 'joeuser@users.local', :first => 'Joe', :last => 'User' }
uri = URI.parse('http://vs.local/t1/st/__api/v1/echo')
req = Net::HTTP::Post.new(uri.path)
req.set_form_data parms

Net::HTTP.start(uri.host, uri.port) do |http|
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