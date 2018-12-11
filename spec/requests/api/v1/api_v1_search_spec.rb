require 'rails_helper'

RSpec.describe "Api::V1::Search", type: :request do
  describe 'GET /api/v1/search' do
    context 'with invalid query params' do
      before do
        user = create(:user)
        
        get '/api/v1/search'
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(json['users'].count).to eql(0) }
      it { expect(json['tweets'].count).to eql(0) }
    end

    context 'with valid query params' do
      before do
        @user = create(:user)
        @user2 = create(:user)
        @user3 = create(:user)

        @tweet = create(:tweet, user: @user)
        @tweet2 = create(:tweet, user: @user2)
        @tweet3 = create(:tweet, user: @user3)

        Tweet.reindex
        User.reindex
      end

      it 'returns the right user' do
        get "/api/v1/search?query=#{@user.name}"
        expect(json['users'][0]).to eql(serialized(Api::V1::UserSerializer, @user))
      end

      it 'returns the right user2' do
        get "/api/v1/search?query=#{@user2.name}"
        expect(json['users'][0]).to eql(serialized(Api::V1::UserSerializer, @user2))
      end

      it 'returns the right user3' do
        get "/api/v1/search?query=#{@user3.name}"
        expect(json['users'][0]).to eql(serialized(Api::V1::UserSerializer, @user3))
      end

      it 'returns the right tweet' do
        get "/api/v1/search?query=#{@tweet.body}"
        expect(json['tweets'][0]).to eql(serialized(Api::V1::TweetSerializer, @tweet))
      end

      it 'returns the right tweet2' do
        get "/api/v1/search?query=#{@tweet2.body}"
        expect(json['tweets'][0]).to eql(serialized(Api::V1::TweetSerializer, @tweet2))
      end

      it 'returns the right tweet3' do
        get "/api/v1/search?query=#{@tweet3.body}"
        expect(json['tweets'][0]).to eql(serialized(Api::V1::TweetSerializer, @tweet3))
      end
    end
  end
end