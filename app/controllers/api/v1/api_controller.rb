module Api
  module V1
    class ApiController < ApplicationController::API
      include Knock::Authenticable
      include CanCan::ControllerAdditions
    end
  end
end
