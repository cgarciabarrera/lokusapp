class Device < ActiveRecord::Base



  after_create :send_device_to_redis

  after_destroy :remove_device_from_redis

  after_update :update_device_on_redis


  validates :name, presence: true

  validates :user, presence: true

  validates :imei, presence: true, :uniqueness => true

  belongs_to :user

  has_many :shareds

  scope :mine, (lambda do |user|
    where('user_id = ?', user.id)
  end)


  def self.last_point(imei)

    key_hour = $redis.smembers(imei + ":h").sort.last

    #
    if key_hour.present?
      eval($redis.zrevrange(imei + ":" + key_hour, 0, 0)[0])
    end




    #    $redis.hgetall(self.imei.to_s + ":d")


  end

  def self.share_with(imei, user, user_shared_to )

    #verificar que el imei sea del usuario,
    #verificar que el destinatario exista

    device = Device.where("imei = ?", imei).first

    Shared.where(:user_id => user, :device => device, :user_shared_id => user_shared_to).destroy_all

    s = Shared.new
    s.user_id = user
    s.device = device
    s.user_shared_id = user_shared_to
    if s.save

      $redis.sadd("us:" + user.to_s, imei.to_s)
      true
    else
      false
    end


  end

  def self.unshare(imei, user, user_shared_to )

    #verificar que el imei sea del usuario,
    #verificar que el destinatario exista

    device = Device.where("imei = ?", imei).first

    Shared.where(:user_id => user, :device => device, :user_shared_id => user_shared_to).destroy_all

    $redis.srem("us:" + user.to_s, imei.to_s)

  end

  def self.last_fix(imei)
    unless Device.last_point(imei).nil?
      DateTime.strptime(Device.last_point(imei)[:tim].to_s, "%s")
    end
  end

  def self.hours_with_points(imei)
    h= $redis.smembers(imei + ":h")
    h.sort
  end

  def self.points_of_hour(imei, hour)
    $redis.zrevrange(imei + ":" + hour, 0, -1)
  end

  def self.points_of_hour_count(imei, hour)
    $redis.zcard(imei + ":" + hour)
  end

  def last_x_points2(quantity)

    points =[]

    #horas_ordenadas
    key_hour = $redis.smembers(self.imei.to_s + ":h").sort.reverse

    #p key_hour

    key_hour.each do |h|
      if self.points_of_hour(h).count + points.count >= quantity

        self.points_of_hour(h)[0..(quantity - points.size - 1)].each do |p|
          points << eval(p)
        end
        break
      else
        self.points_of_hour(h).each do |p|
          points << eval(p)
        end
      end

    end

    points

  end



  def self.last_x_points(imei, quantity)

    points =[]

    #horas_ordenadas
    key_hour = $redis.smembers(imei + ":h").sort.reverse

    #p key_hour

    key_hour.each do |h|
      if Device.points_of_hour(imei,h).count + points.count >= quantity

        Device.points_of_hour(imei, h)[0..(quantity - points.size - 1)].each do |p|
          points << eval(p)
        end
        break
      else
        Device.points_of_hour(imei, h).each do |p|
          points << eval(p)
        end
      end

    end

    points

  end



  def self.total_points(imei)

    c = 0
    Device.hours_with_points(imei).each do |h|
      c = c + Device.points_of_hour_count(imei,h)
    end

    c

  end

  def update_device_on_redis

    $redis.hset(self.imei.to_s + ":d", "name", self.name.to_s)

  end


  def send_device_to_redis

    # al crear un nuevo device
    # crea un set inicial con el user id al que pertenece
    $redis.hset(self.imei.to_s + ":d" , "usr", self.user.id.to_s)
    $redis.hset(self.imei.to_s + ":d", "dev", self.id.to_s)
    $redis.hset(self.imei.to_s + ":d", "tim", 0)
    $redis.hset(self.imei.to_s + ":d", "name", self.name.to_s)


    $redis.sadd("u:" + self.user.id.to_s, self.imei.to_s)


  end


  def remove_device_from_redis


    #borro cada key con puntos de cada hora
    $redis.smembers(self.id.to_s + ":h").each do |h|
      $redis.del(self.id.to_s + ":" + h)
    end

    #borro la lista de horas con puntos
    $redis.del(self.id.to_s + ":h")

    #borro la lista de puntos minimos
    $redis.del(self.id.to_s + ":m")

    $redis.del(self.id.to_s + ":d")

    $redis.srem("u:" + self.user.id.to_s, self.id.to_s)


  end


  def self.imei_belongs_to_user?(user_id, imei)

    $redis.smembers("u:" + user_id.to_s).include? imei

  end

  def self.points_interval(imei, start_timestamp, end_timestamp)
    start_f = DateTime.strptime(start_timestamp.to_s,'%s').strftime("%y%m%d%H")
    end_f = DateTime.strptime(end_timestamp.to_s,'%s').strftime("%y%m%d%H")
    hours = Device.hours_with_points(imei)

    min_hour = Functions.find_closest_low(hours, start_f.to_f)
    max_hour = Functions.find_closest_high(hours, end_f.to_f)

    p hours[min_hour]
    p hours[max_hour]

    points = []
    hours[min_hour..max_hour].each do |i|
      Device.points_of_hour(imei, i.to_s).each do |p|
        points << eval(p)
      end
    end

    points

  end


  def self.new_point(device_imei, device_datetime, device_latitude, device_longitude, device_speed, device_altitude, device_course, device_extended)

    if device_imei.present?

      imei= device_imei
      #fix_time = params[:datetime]

      user_id = $redis.hget(imei.to_s + ":d", "usr")

      if user_id.nil?
        #render :text => ("KO imei no existe en redis")

        return -1
      end

      fix_time = device_datetime

      #p "diferencia: " + (fix_time.to_i - $redis.hget("d:" + imei.to_s, "tim").to_i).to_s

      #if  fix_time.to_i - $redis.hget("d:" + imei.to_s, "tim").to_i < 8
      #  render :text => ("Mucha prisa")
      #  return
      #end

      @did = imei

      t = DateTime.strptime(fix_time.to_s,'%s').strftime("%y%m%d%H").to_i

      #gps_data = "{:l => 2, :LN => 3, :tm => " + Time.now.to_f.to_s + "}"

      #datos del punto

      lat = device_latitude
      lon = device_longitude
      speed = device_speed
      altitude= device_altitude
      course = device_course

      extended=device_extended
      accuracy = "0"

      #gps_data = ["lat", lat, "lon", lon, "spd", speed, "alt", altitude, "tim", fix_time, "crs", course, "ext", extended]

      #gps_data_json = {:lat => lat, :lon=> lon, :spd => speed, :alt => altitude, :tim => fix_time, :crs => course, :ext => extended}.to_json

      #gps_data = {lat: lat, lon: lon, spd: speed, alt: altitude, tim: fix_time, crs: course, ext: extended }
      gps_data = {lat: lat.to_f, lon: lon.to_f, spd: speed.to_i, alt: altitude.to_i, tim: fix_time.to_f, crs: course.to_i, ext: extended }


      $redis.mapped_hmset(imei + ":d",  gps_data)

      expire_time = 31536000 #en segundos

      keyHour = @did.to_s + ":h"
      keyData = @did.to_s + ":" +  t.to_s
      keyMinData = @did.to_s + ":m"

      #lista contenedora de horas con datos
      #modelo: id_device : YYYYMMDDhh

      if $redis.sadd(keyHour, t)
        #si no hay datos de esa hora en la coleccion de horas del dispositivo, entonces lo graba
        # leer lista-> smembers 1:h
        $redis.zadd(keyMinData, t, gps_data )         #Leer datos de dentro->   zrange 1:m 0 -1
      end
      #se lee con
      # smembers 1:h

      #lista contenedora de datos de un device una hora en concreto
      #modelo: id_device:YYYYMMDDhh orden  valor = gps data
      $redis.zadd(keyData, fix_time, gps_data)         #Leer contenido con : zrange 1:14082616 0 -1
      $redis.expire(keyData, expire_time)

      #render :text => ("OK")
      true
    else
      #render :text => ("KO IMEI no es parametro")
      false
    end
  end


  def self.find_closest(array, value,tmpmax=1)
    p_from=0
    p_max=array.count-1
    p_to=p_max
    if value>=array[p_to]
      return p_to
    elsif value<=array[0]
      return 0
    end

    while
      p_mid=(p_to+p_from) /2
      p_valormid=array[p_mid]


      if value < p_valormid

        p_to=p_mid-1

      elsif value > p_valormid

        p_from=p_mid+1

      else

        return p_mid
      end

      if p_to<p_from
        if tmpmax==1
          return p_from
        else
          return p_to
        end
      end
    end
  end



end
