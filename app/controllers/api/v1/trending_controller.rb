class Api::V1::TrendingController < Api::V1::ApiController
  def index
    @trendings = Trending.last
    render json: @trendings
  end
end
