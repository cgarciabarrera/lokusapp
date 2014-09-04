class Device < ActiveRecord::Base



  after_create :send_device_to_redis


  validates :name, presence: true

  validates :user, presence: true

  validates :imei, presence: true

  belongs_to :user


  def last_point

    #key_hour = $redis.smembers(self.imei.to_s + ":h").sort.last
    #
    #key_data = $redis.zrevrange(self.imei.to_s + ":" + key_hour, 0, 0)[0]

    $redis.hgetall("d:" + self.imei.to_s)


  end

  def hours_with_points
    $redis.smembers(self.imei.to_s + ":h")
  end

  def points_of_hour(hour)
    $redis.zrevrange(self.imei.to_s + ":" + hour, 0, -1)
  end




  def send_device_to_redis

    # al crear un nuevo device
    # crea un set inicial con el user id al que pertenece
    $redis.hset("d:" + self.imei.to_s, "usr", self.user.id.to_s)
    $redis.hset("d:" + self.imei.to_s, "dev", self.id.to_s)
    $redis.hset("d:" + self.imei.to_s, "tim", 0)

    $redis.sadd("u:" + self.user.id.to_s, self.imei.to_s)


  end

  def new_point(lat, lon, speed, c)

  end

end
