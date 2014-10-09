class Functions

  def self.find_closest_high(array, value)
    array.sort.each_with_index do |a, index|

      if a.to_f >= value
        return index
      end
    end
    array.count -1
  end


  def self.find_closest_low(array, value)
    array.sort.reverse.each_with_index do |a, index|
      if a.to_f <= value
        return index
      end
    end
    0
  end



  def self.stress(long_array, iterations)

    #llamar en cosola como Functions.stress(50000, 10) y ordenara un array de 50000 elementos 10 veces y dira loque tarda
    a = []
    long_array.times do |d|
      a << rand(1..3000000)
    end
    ini = Time.now
    iterations.times do
      Functions.find_closest_high(a, rand(1..3000000) )
    end

    p (iterations / (Time.now.to_f - ini.to_f)).to_s + " / seg"


  end

end