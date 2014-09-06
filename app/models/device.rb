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

    $redis.hgetall(self.imei.to_s + ":d")


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
