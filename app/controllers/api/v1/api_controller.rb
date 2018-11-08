module Api
  module V1
    class ApiController < ApplicationController::API
      include Knock::Authenticable
    end
  end
end