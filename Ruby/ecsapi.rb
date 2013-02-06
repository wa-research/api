require 'net/http'

class Hash 
    def to_params
      params = ''
      stack = []

      each do |k, v|
        if v.is_a?(Hash)
          stack << [k,v]
        else
          params << "#{k}=#{v}&"
        end
      end

      stack.each do |parent, hash|
        hash.each do |k, v|
          if v.is_a?(Hash)
            stack << ["#{parent}[#{k}]", v]
          else
            params << "#{parent}[#{k}]=#{v}&"
          end
        end
      end

      params.chop! # trailing &
      params
    end
end

class ECSApi
    
    def gettime(options)
        time = localtime = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S")
        if (options.sync_time)
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
        time = gettime(options)
        require "digest/sha1"
        # operation site-id password request-time, example: adduser wa 1 time
        sig = Digest::SHA1.hexdigest("#{operation}#{options.user}#{options.key}#{time}")
        return time, sig
    end

    def apiurl(operation, options, parms = {})
        time, sig = sign(operation, options)
        qoramp = options.url.include?("?") ? "&" : "?"
        apiurl = "#{options.server}#{options.url}/#{operation}#{qoramp}site-id=#{options.user}&request-time=#{time}&signature=#{sig}"
        parms["verbose"] = true if options.verbose
        parms = parms.merge!(options.params) if options.params
        apiurl = apiurl + "&" + parms.to_params if parms.length > 0
        return apiurl
    end
end

def get_response_with_redirect(uri)
   r = Net::HTTP.get_response(uri)
   while r.code == "301"
     r = Net::HTTP.get_response(URI.parse(r['location']))
   end
   r
end