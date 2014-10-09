module ApplicationHelper


  def find_closest_big(array, value)
    array.sort.each_with_index do |a, index|
      if a[index].to_f >= value
        return a[index]
      end
    end
    -1
  end

end
