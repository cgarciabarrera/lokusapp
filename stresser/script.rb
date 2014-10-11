require 'open-uri'
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



actual_line = 0

10.times do
  File.open(filename, "r").each_line do |line|
    actual_line = actual_line + 1

    if actual_line >= avoid_lines
      data = line.split(",")
      #p data[0] + "---" + data[1]


      url = URI.parse("http://new.lokusapp.com/api/v1/devices/new_point?imei=" + imei + "&datetime=" + Time.now.to_f.to_s + "&accuracy=0&latitude=" + data[0] + "&longitude=" + data[1] + "&speed=89&altitude=5&course=23&extended=r")
      begin
        open(url) do |http|
#        response = http.read
#  puts "response: #{response.inspect}"
        end
      rescue Exception
        puts $!, $@

      end

#      p "latitude=" + data[0] + "&longitude=" + data[1]
      i = i + 1
      if i % 1000 == 0
       # p "1000 mas del imei " + imei.to_s
      end

      sleep 0.5

    end

  end
  avoid_lines = 0

end