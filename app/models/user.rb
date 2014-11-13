class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #before_save :ensure_authentication_token
  after_save :ensure_authentication_token

  def ensure_authentication_token
      #p "Busco por " + "*:u:" + id.to_s
      $redis.keys("*:u:" + id.to_s).each do |tk|
        $redis.del(tk)
      end

      $redis.set("t:" + generate_authentication_token + ":u:" + id.to_s, self.id.to_i )

  end

  has_many :devices, :dependent => :destroy

  has_many :shareds

  has_many :alarms , :dependent => :destroy

  has_many :locations, :dependent => :destroy

  has_many :shareds_with_me, :foreign_key => 'user_shared_id', :class_name => "Shared"

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token

      #pasar esto a redis

      #break token unless User.where(authentication_token: token).first
      break token unless $redis.keys("t:" + token + ":u:*").present?

    end
  end


end
