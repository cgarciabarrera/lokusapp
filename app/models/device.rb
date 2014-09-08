class Device < ActiveRecord::Base



  after_create :send_device_to_redis


  validates :name, presence: true

  validates :user, presence: true

  validates :imei, presence: true, :uniqueness => true

  belongs_to :user


  def last_point

    key_hour = $redis.smembers(self.imei.to_s + ":h").sort.last

    #
    if key_hour.present?
      JSON.parse($redis.zrevrange(self.imei.to_s + ":" + key_hour, 0, 0)[0])
    end




    #    $redis.hgetall(self.imei.to_s + ":d")


  end

  def last_fix
    DateTime.strptime(self.last_point["tim"], "%s")
  end

  def hours_with_points
    h= $redis.smembers(self.imei.to_s + ":h")
    h.sort
  end

  def points_of_hour(hour)
    $redis.zrevrange(self.imei.to_s + ":" + hour, 0, -1)
  end

  def points_of_hour_count(hour)
    $redis.zrevrange(self.imei.to_s + ":" + hour, 0, -1).count
  end

  def last_x_points(quantity)

    points =[]

    #horas_ordenadas
    key_hour = $redis.smembers(self.imei.to_s + ":h").sort.reverse

    p key_hour

    key_hour.each do |h|
      if self.points_of_hour(h).count + points.count >= quantity

        self.points_of_hour(h)[0..(quantity - points.size - 1)].each do |p|
          points << JSON.parse(p)
        end
        break
      else
        self.points_of_hour(h).each do |p|
          points << JSON.parse(p)
        end
      end

    end

    points



  end





  def send_device_to_redis

    # al crear un nuevo device
    # crea un set inicial con el user id al que pertenece
    $redis.hset(self.imei.to_s + ":d" , "usr", self.user.id.to_s)
    $redis.hset(self.imei.to_s + ":d", "dev", self.id.to_s)
    $redis.hset(self.imei.to_s + ":d", "tim", 0)

    $redis.sadd("u:" + self.user.id.to_s, self.imei.to_s)


  end

  def new_point(lat, lon, speed, c)

  end

end
