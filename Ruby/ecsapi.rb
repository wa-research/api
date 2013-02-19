require 'net/http'

class ECSApi
    
    def gettime(operation, options)
        time = localtime = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S")
        if (options.sync_time && operation != 'time')
            url = URI.parse(options.server)
            begin
                Net::HTTP.start(url.host, url.port) do |http|
                    req = Net::HTTP::Get.new('/__api/v1/time')
                    response = http.request(req)
                    time = response.body if response.code == '200'
                    #re-do local time as the request might have taken a few seconds
                    localtime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
                end
            rescue Exception => e
                $stderr.puts "ERROR: Could not synchronize time. Is URL #{url} accessible? Using local time: #{time}"
            end
        end
        time
    end

    def sign(operation, options)
        time = gettime(operation, options)
        require "digest/sha1"
        # operation site-id password request-time, example: adduser wa 1 time
        sig = Digest::SHA1.hexdigest("#{operation}#{options.user}#{options.key}#{time}")
        return time, sig
    end

end