class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :tweets_count, :followers_count, :following_count

  def tweets_count
    object.tweets.count
  end

  def followers_count
    object.followers_by_type('User').count
  end

  def following_count
    object.following_users.count
  end
end
