class Shared < ActiveRecord::Base

belongs_to :user

belongs_to :user_shared, :class_name => 'User', :foreign_key => 'user_shared_id'





end
