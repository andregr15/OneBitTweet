require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'timeline' do
    before do
      @user = create(:user)
      @other_user = create(:user)
      @user.follow(@other_user)

      tweets = Random.rand(0..25)

      tweets.times do 
        create(:tweet, user: @user) 
        create(:tweet, user: @other_user)
      end
    end

    it 'has the right number of tweets' do
      expect(@user.timeline.count).to eql(@user.tweets.count + @other_user.tweets.count)
    end
    
    it 'has the right tweets' do
      timeline = @user.tweets.map { |tweet| tweet }
      timeline += @other_user.tweets.map { |tweet| tweet }

      expect(timeline.sort_by!(&:created_at).reverse).to eql(@user.timeline)
    end
  end
end
