class Functions

  def self.find_closest_high(array, value)
    # array.each_with_index do |a, index|
    #
    #   if a.to_f >= value
    #     return index
    #   end
    # end
    # array.count -1
    self.find_closest(array, value, 1)
  end


  def self.find_closest_low(array, value)
    # array.reverse.each_with_index do |a, index|
    #   if a.to_f <= value
    #     return index
    #   end
    # end
    # 0
    self.find_closest(array, value)
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

    p "C: " + ((Time.now.to_f - ini.to_f)).to_s + " seg"

    ini = Time.now
    iterations.times do
      Functions.find_closest(a, rand(1..3000000) )
    end

    p "D: " + (Time.now.to_f - ini.to_f).to_s + " seg"



  end


  def self.find_closest(array, value,tmpmax = 1)

    #creada por daniel


    p_from=0
    p_max=array.count-1
    p_to=p_max
    if value>=array[p_to]
      return p_to
    elsif value<=array[0]
      return 0
    end

    while
    p_mid = (p_to+p_from) / 2
      p_valormid = array[p_mid]


      if value < p_valormid

        p_to=p_mid-1

      elsif value > p_valormid

        p_from=p_mid+1

      else

        return p_mid
      end

      if p_to < p_from
        if tmpmax == 1
          return p_from
        else
          return p_to
        end
      end
    end
  end


end