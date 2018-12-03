class Api::V1::TweetSerializer < ActiveModel::Serializer
  attributes :id, :body, :tweet_original_id, :retweets_count, :likes_count, :liked
  belongs_to :tweet_original
  belongs_to :user

  def tweet_original
    options = { each_serializer: Api::V1::TweetSerializer }
    ActiveModelSerializers::SerializableResource.new(object.tweet_original, options) if object.tweet_original
  end

  def user 
    options = { each_serializer: Api::V1::UserSerializer }
    ActiveModelSerializers::SerializableResource.new(object.user, options)
  end

  def retweets_count
    object.retweets.count
  end

  def likes_count
    object.votes_for.size
  end

  def liked
    # scope = current_user (seted on api_controller by serialization_scope :current_user)
    (scope)? (scope.liked? object) : false
  end
end
