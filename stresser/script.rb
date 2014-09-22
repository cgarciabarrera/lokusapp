require 'open-uri'
i=0
imei = ARGV[0]
dir = ARGV[1]

filename=""
if dir == "0"
  filename = "points.txt"
else
  filename = "points_rev.txt"
end
File.open(filename, "r").each_line do |line|
  data = line.split(",")
  #p data[0] + "---" + data[1]


  url = URI.parse("http://localhost:3000/devices/new_point?imei=" + imei + "&datetime=" + Time.now.to_f.to_s + "&accuracy=0&latitude=" + data[0] + "&longitude=" + data[1] + "&speed=89&altitude=5&course=23&extended=r")
  open(url) do |http|
    #        response = http.read
    #  puts "response: #{response.inspect}"
  end
  i = i + 1
  if i % 1000 == 0
    p "1000 mas"
  end
  sleep 0.5
end
