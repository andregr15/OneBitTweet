class AddPhotoToTweet < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :photo, :string
  end
end
