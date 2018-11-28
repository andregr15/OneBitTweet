require 'rails_helper'

RSpec.describe "Api::V1::Tweets", type: :request do
  describe 'GET /api/v1/tweets?user_id=:id&page=:page' do
    context 'when user exists' do
      before do
        @user = create(:user)
        tweets_number = Random.rand(15..25)

        tweets_number.times { create(:tweet, user: @user) }
      end

      it 'should have returned the http status success' do
        get "/api/v1/tweets?user_id=#{@user.id}&page=1", headers: header_with_authentication(@user)
        expect_status(:success)
      end

      it 'should have returned the right tweets' do
        get "/api/v1/tweets?user_id=#{@user.id}&page=1", headers: header_with_authentication(@user)
        expect(json).to eql(each_serialized(Api::V1::TweetSerializer, @user.tweets[0..14]))
      end

      it 'should have returned 15 elements on first page' do
        get "/api/v1/tweets?user_id=#{@user.id}&page=1", headers: header_with_authentication(@user)
        expect(json.count).to eql(15)
      end

      it 'should have returned the remaining elements on second page' do
        get "/api/v1/tweets?user_id=#{@user.id}&page=2", headers: header_with_authentication(@user)
        remaining = @user.tweets.count - 15
        expect(json.count).to eql(remaining)
      end
    end

      # Verifique se os tweets que são retweets possuem os tweets originais associados

    context 'when user do not exists' do
      before do
        user = create(:user)
        user_id = -1

        get "/api/v1/tweets?user_id=#{user_id}&page=1", headers: header_with_authentication(user)
      end

      it 'should have returned the http status not found' do
        expect_status(:not_found)
      end
    end
  end
  
  describe 'GET /api/v1/tweets/:id' do
    context 'when the tweet exists' do
      before do
        @user = create(:user)
      end

      context 'when the tweet is regular' do
        before do
          @tweet = create(:tweet)
          get "/api/v1/tweets/#{@tweet.id}"
        end

        it 'should have returned the http status success' do
          expect_status(:success)
        end

        it 'should have returned a valid tweet in json' do
          expect(json).to eql(serialized(Api::V1::TweetSerializer, @tweet))
        end

        it 'should have checked if the tweet owner is present' do
          expect(json['user']).to eql(serializerd(Api::V1::UserSerializer, @tweet.user))
        end
      end

      context 'when the tweet is a retweet' do
        before do
          @tweet_original = create(:tweet)
          @tweet = create(:tweet, tweet_original: @tweet_original)

          get "/api/v1/tweets/#{@tweet.id}"
        end

        it 'should have returned the http status success' do
          expect_status(:success)
        end

        it 'should have returned a valid tweet in json' do
          expect(json).to eql(serialized(Api::V1::TweetSerializer, @tweet))
        end

        it 'should have checked if the tweet owner is present' do
          expect(json['user']).to eql(serialized(Api::V1::UserSerializer, @tweet.user))
        end

        it 'should have checked if the tweet original is present' do
          expect(json['tweet_original']).to eql(serialized(Api::V1::TweetSerializer, @tweet_original))
        end
      end

      context 'when tweet do not exists' do
        before do
          tweet_id = -1
          get "/api/v1/tweets/#{tweet_id}"
        end

        it 'should have returned the http status not found' do
          expect_status(:not_found)
        end
      end

    end

  end
end
