module Api
  module V1
    class UserTokenController < Knock::AuthTokenController
      # ajust to knock work on rails 5.2
      skip_before_action :verify_authenticity_token
    end
  end
end
