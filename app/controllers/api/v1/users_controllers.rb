class Api::V1::UsersController < Api::V1::CommonController

  before_action :set_user, except: [:register]


  def register_user
    if params[:email].present? && params[:password].present? && params[:nickname].present?

      u = User.new
      u.email = params[:email]

    end

  end

end