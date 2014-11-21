class Item < ActiveRecord::Base

  #require 'carrierwave/orm/activerecord'


  mount_uploader :picture, ItemUploader

end
