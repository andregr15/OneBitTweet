require 'rails_helper'

RSpec.describe 'Api::V1::Timelines', type: :request do
  describe 'GET /api/v1/timeline' do
    context 'with invalid credentials' do
      it_behaves_like :deny_without_authorization, :get, '/api/v1/timeline'
    end

    context 'with valid credentials' do
      before do
        @user = create(:user)
        @other_user = create(:user)
        @user.follow(@other_user)

        tweets = Random.rand(15..25)
        tweets_other_user = Random.rand(1..4)

        tweets.times { create(:tweet, user: @user) }
        tweets_other_user.times { create(:tweet, user: @other_user) }

        get '/api/v1/timeline', headers: header_with_authentication(@user)
      end

      it { expect(response).to have_http_status(:success) }

      it 'have 15 elements on first page' do
        expect(json.count).to eql(15)
      end

      it 'have returned the correct tweets on first page' do
        expect(json).to eql(JSON.parse(each_serialized(Api::V1::TweetSerializer, @user.timeline.paginate(page: 1))))
      end

      it 'have the remaining elements on second page' do
        get '/api/v1/timeline?page=2', headers: header_with_authentication(@user)
        remaining = @user.tweets.count + @other_user.tweets.count - 15;
        expect(json.count).to eql(remaining)
      end

      it 'have returned the correct tweets on second page' do
        get '/api/v1/timeline?page=2', headers: header_with_authentication(@user)
        expect(json).to eql(JSON.parse(each_serialized(Api::V1::TweetSerializer, @user.timeline.paginate(page: 2))))
      end

    end
  end
end