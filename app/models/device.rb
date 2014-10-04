class Device < ActiveRecord::Base



  after_create :send_device_to_redis


  validates :name, presence: true

  validates :user, presence: true

  validates :imei, presence: true, :uniqueness => true

  belongs_to :user

  scope :mine, (lambda do |user|
    where('user_id = ?', user.id)
  end)


  def last_point

    key_hour = $redis.smembers(self.imei.to_s + ":h").sort.last

    #
    if key_hour.present?
      eval($redis.zrevrange(self.imei.to_s + ":" + key_hour, 0, 0)[0])
    end




    #    $redis.hgetall(self.imei.to_s + ":d")


  end

  def last_fix
    unless self.last_point.nil?
      DateTime.strptime(self.last_point[:tim].to_s, "%s")
    end
  end

  def hours_with_points
    h= $redis.smembers(self.imei.to_s + ":h")
    h.sort
  end

  def points_of_hour(hour)
    $redis.zrevrange(self.imei.to_s + ":" + hour, 0, -1)
  end

  def points_of_hour_count(hour)
    $redis.zcard(self.imei.to_s + ":" + hour)
  end

  def last_x_points(quantity)

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


  def total_points

    c = 0
    self.hours_with_points.each do |h|
      c = c + self.points_of_hour_count(h)
    end

    c

  end


  def send_device_to_redis

    # al crear un nuevo device
    # crea un set inicial con el user id al que pertenece
    $redis.hset(self.imei.to_s + ":d" , "usr", self.user.id.to_s)
    $redis.hset(self.imei.to_s + ":d", "dev", self.id.to_s)
    $redis.hset(self.imei.to_s + ":d", "tim", 0)

    $redis.sadd("u:" + self.user.id.to_s, self.imei.to_s)


  end

  def self.imei_belongs_to_user?(user_id, imei)

    $redis.smembers("u:" + user_id.to_s).include? imei

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

      t = DateTime.strptime(fix_time.to_s,'%s').strftime("%y%m%d%H")

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
      keyData = @did.to_s + ":" +  t
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

end
