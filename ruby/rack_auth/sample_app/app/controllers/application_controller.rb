class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    sleep 3.14
    render :text => "Hola"
  end
end
