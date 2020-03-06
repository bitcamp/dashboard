module Api
  class Api::ApiController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :auth_user
  before_action :set_raven_context
  after_action  :set_access_control_headers
  after_action  :set_extra_headers

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end

  def index
    render json: {}
  end

  def lookup_user
    return head :unauthorized if @current_user.nil?
    return head :bad_request if request.body.nil?

    r = JSON.parse request.body.read

    return head :bad_request if r["email"].nil?

    user = User.where(:email => r["email"]).first

    return head :not_found if user.nil?

    j = user.to_json

    z = {}


    if user.has_applied?
      app = EventApplication.where(:user_id => user.id).first
      z["food_restrictions"] = app["food_restrictions"]
      z["food_restrictions_info"] = app["food_restrictions_info"]
      z["t_shirt_size"] = app["t_shirt_size"]
    end

    x = {
      "user": user,
    }.merge(z)

    render json: x
  end
end
end
