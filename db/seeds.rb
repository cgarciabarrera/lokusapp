# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

$redis.flushdb


puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name(role)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name
user.add_role :admin


Device.create(:name => "Device 0", :imei => "0", :user => User.first)

u = User.create(:name => "Carlos 1", :email => "user1@example.com", :password => "changeme")
Device.create(:name => "Device 1", :imei => "1", :user => u)


u = User.create(:name => "Carlos 2", :email => "user2@example.com", :password => "changeme")
Device.create(:name => "Device 2", :imei => "2", :user => u)


i= Item.create(:name => 'navegagrande', :price => '95.99', :tax => 21,:picture => File.open("images_demo/gps1.jpg"))

i= Item.create(:name => 'naveganiñoe', :price => '55.45', :tax => 10)
i= Item.create(:name => 'navegabici', :price => '55.5', :tax => 21)





# 10.times.each do |dd|
#   d = dd + 1
#   Device.create(:imei => d.to_s, :user => User.last, :name => "Device " + d.to_s)
#   4.times.each_with_index do |x, p|
#     Device.new_point(d.to_s,(Time.now - (400 - p).hours).to_f,(1 + (p/200.to_f)).to_f,(7 + (p/200.to_f)).to_f,(190 + (p/200.to_f)).to_f,120,34,nil)
#   end
#   p "creando device " +  d.to_s
# end
#
#
# Device.create(:imei => "862304020094218", :user => User.last, :name => "Moto Luis") #862304020094218
# Device.create(:imei => "359710041641748", :user => User.last, :name => "Jaguar Luis") #862304020094218
# Device.create(:imei => "359710041641623", :user => User.last, :name => "Mazda Carlos") #862304020094218

