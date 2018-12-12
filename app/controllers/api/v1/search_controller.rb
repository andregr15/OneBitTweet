class Api::V1::SearchController < Api::V1::ApiController
  before_action :set_page
  
  def index
    tweets = Tweet.search(params[:query], page: @page)
    users = User.search(params[:query], page:  @page)

    tweets_json = ActiveModelSerializers::SerializableResource.new(tweets, each_serializer: Api::V1::TweetSerializer)
    users_json = ActiveModelSerializers::SerializableResource.new(users, each_serializer: Api::V1::UserSerializer)

    render json: { tweets: tweets_json, users: users_json}
  end

  def autocomplete  
    ret = Tweet.search(
      params[:query], {
        fields: ['body'],
        match: :word_start,
        limit: 10,
        load: false,
        misspellings: { bellow: 5 }
      }).map(&:body)

    ret += User.search(params[:query], {
      fields: ["name"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map(&:name)

    render json: { results: ret }
  end

  private

  def set_page
    @page = (params[:page] || 1)
  end
end
