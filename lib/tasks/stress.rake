task :crear100 => :environment do


  i = 0
  100.times do |u|
    i = i + 1
    u = User.create(:name => i.to_s, :email => "pepestress" + i.to_s + "@pepe.com", :password => "Pepe0101")

    Device.create(:name => i.to_s, :imei => (1000 + i).to_s, :user => u)

  end

end
