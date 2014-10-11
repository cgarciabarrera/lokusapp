require 'open-uri'
require 'json'
i=0
imei = ARGV[0]
dir = ARGV[1]

filename=""
if dir == "1"
  filename = "1.txt"
else
  filename = "2.txt"
end
File.open(filename, "r").each_line do |line|
  i = i + 1

end

avoid_lines = (1..(i - 1)).to_a.sample

auth=""

actual_line = 0
i = 0
10.times do
  File.open(filename, "r").each_line do |line|
    actual_line = actual_line + 1

    if actual_line >= avoid_lines
      data = line.split(",")
      #p data[0] + "---" + data[1]

      if i % 50 == 0

        url = URI.parse("http://new.lokusapp.com/api/v1/sessions/?email=pepe_stress" + imei + "@pepe.com&password=Pepe0101")
        begin
          open(url) do |http|
            response = JSON.parse(http.read)
            if response["success"]
              auth = response["auth_token"]
              #p auth
            end
          end
        rescue
        end
      end

      url = URI.parse("http://new.lokusapp.com/api/v1/devices/new_point_mobile?user_token=" + auth + "&imei=" + (imei.to_i + 1000).to_s + "&datetime=" + Time.now.to_f.to_s + "&accuracy=0&latitude=" + data[0] + "&longitude=" + data[1] + "&speed=89&altitude=5&course=23&extended=r")
      begin
        open(url) do |http|
          response = JSON.parse(http.read)
          response["success"] ? "OK" : "Error"
          #  puts "response: #{response.inspect}"
        end
      rescue
        p "Mal"
      end


      sleep 0.5

      i = i + 1

    end

  end
  avoid_lines = 0

end
