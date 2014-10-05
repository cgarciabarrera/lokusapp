# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name(role)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name
user.add_role :admin

$redis.flushdb

100.times.each do |dd|
  d = dd + 1
  Device.create(:imei => d.to_s, :user => User.last, :name => "Device " + d.to_s)
  200.times.each_with_index do |x, p|
    Device.new_point(d.to_s,Time.now.to_f,(1 + (p/200.to_f)).to_f,(7 + (p/200.to_f)).to_f,(190 + (p/200.to_f)).to_f,120,34,nil)
  end
  p "creando device " +  d.to_s
end



