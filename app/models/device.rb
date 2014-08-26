class Device < ActiveRecord::Base


  validates :name, presence: true


  belongs_to :user


  def last_point

    key_hour = $redis.smembers(self.id.to_s + ":h").sort.last

    key_data = $redis.zrevrange(self.id.to_s + ":" + key_hour, 0, 0)[0]

  end

  def hours_with_points
    $redis.smembers(self.id.to_s + ":h")
  end

  def points_of_hour(hour)
    $redis.zrevrange(self.id.to_s + ":" + hour, 0, -1)
  end

end
