class Api::V1::SessionsController < DeviseController
  skip_before_filter :verify_authenticity_token
  prepend_before_filter :require_no_authentication, :only => [:create ]
  before_filter :ensure_params_exist, except: :destroy

  respond_to :json

  def create
    resource = User.find_for_database_authentication(:email=>params[:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      resource = renew_authentication_token(resource)
      #sign_in("user", resource) no vamos a utilizar sesiones
      #api_ok( :auth_token=>resource.authentication_token)
      render :json=> {:success=>true, :auth_token=>resource.authentication_token, :email=>resource.email}
      return
    end
    invalid_login_attempt
  end

  def destroy
    #sign_out(resource_name) no vamos a utilizar sesiones
    renew_authentication_token(User.find_by_authentication_token(params[:user_token].to_s))
    render :json=>{:success=>true, :message=>"Session destroyed"}, :status=>200
  end

  protected

  def ensure_params_exist
    return unless params[:email].blank? || params[:password].blank?
    render :json=>{:success=>false, :message=>"Missing user parameters"}, :status=>422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json=> { :success=>false, :message=>"Error with your login or password"}, :status=>401
  end

  def renew_authentication_token(user)
    if user
      user.authentication_token = nil
      user.save!
    end
    user
  end

end