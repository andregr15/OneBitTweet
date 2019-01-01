class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :email, :tweets_count, :followers_count, :following_count, :photo, :followed

  def tweets_count
    object.tweets.count
  end

  def followers_count
    object.followers_by_type('User').count
  end

  def following_count
    object.following_users.count
  end

  def followed
    #local_variables.include?(:current_user)? (current_user.following? object) : false
    (defined?(scope) && !scope.nil?) ?  (scope.following? object) : false
  end
end
