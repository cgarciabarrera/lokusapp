class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :devices

  has_many :shareds

  has_many :shareds_with_me, :foreign_key => 'user_shared_id', :class_name => "Shared"

  def devices_positions

    dev = []
    $redis.smembers("u:" + self.id.to_s).each do |d|
      dev << $redis.hgetall("d:" + d.to_s )
    end

    dev

  end


end
