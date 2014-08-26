class Device < ActiveRecord::Base


  validates :name, presence: true


  belongs_to :user


  def last_point

    key_hour = $redis.smembers(self.id.to_s + ":h").sort.last

    key_data = $redis.zrange(self.id.to_s + ":" + key_hour, 0, -1).sort.last



  end

end
