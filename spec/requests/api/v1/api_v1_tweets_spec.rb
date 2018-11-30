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
        expect(response).to have_http_status(:success)
      end

      it 'should have returned the right tweets' do
        get "/api/v1/tweets?user_id=#{@user.id}&page=1", headers: header_with_authentication(@user)
        expect(json).to eql(JSON.parse(each_serialized(Api::V1::TweetSerializer, @user.tweets[0..14])))
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
        expect(response).to have_http_status(:not_found)
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
          expect(response).to have_http_status(:success)
        end

        it 'should have returned a valid tweet in json' do
          expect(json).to eql(serialized(Api::V1::TweetSerializer, @tweet))
        end

        it 'should have checked if the tweet owner is present' do
          expect(json['user']).to eql(serialized(Api::V1::UserSerializer, @tweet.user))
        end
      end

      context 'when the tweet is a retweet' do
        before do
          @tweet_original = create(:tweet)
          @tweet = create(:tweet, tweet_original: @tweet_original)

          get "/api/v1/tweets/#{@tweet.id}"
        end

        it 'should have returned the http status success' do
          expect(response).to have_http_status(:success)
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
          expect(response).to have_http_status(:not_found)
        end
      end

    end

  end

  describe 'POST /api/v1/tweets/' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :post, '/api/v1/tweets/'
    end

    context 'Authenticated' do
      before do
        @user = create(:user)
      end

      context 'with valid params' do
        context 'when the tweet is regular' do
          before do
            @tweet_params = attributes_for(:tweet)
            post '/api/v1/tweets/', params: { tweet: @tweet_params }, headers: header_with_authentication(@user)
          end

          it 'should have returned the http status created' do
            expect(response).to have_http_status(:created)
          end

          it 'should have returned the right tweet in json' do
            expect(json).to include_json(@tweet_params)
          end

          it 'should have created the tweet' do
            expect(Tweet.count).to eql(1)
          end
        end

        context 'when the tweet is a retweet' do
          before do
            @tweet_original = create(:tweet)
            @tweet_params = attributes_for(:tweet, tweet_original_id: @tweet_original.id)

            post '/api/v1/tweets/', params: { tweet: @tweet_params }, headers: header_with_authentication(@user)
          end

          it 'should have returned the http status created' do
            expect(response).to have_http_status(:created)
          end

          it 'should have returned the right tweet in json' do
            expect(json).to include_json(@tweet_params)
          end

          it 'should have returned the right original tweet in json' do
            expect(json['tweet_original']).to eql(serialized(Api::V1::TweetSerializer, @tweet_original))
          end

          it 'should have created the tweet' do
            expect(Tweet.count).to eql(2)
          end
        end
      end

      context 'with invalid params' do
        before do
          tweet_params = { foo: :bar }
          post '/api/v1/tweets/', params: { tweet: tweet_params}, headers: header_with_authentication(@user)
        end

        it 'should have returned the http status unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

    end

  end

  describe 'DELETE /api/v1/tweets/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/tweets/-1'
    end

    context 'Authenticated' do
      context 'when user is the resource owner' do
        before do
          @user = create(:user)
          @tweet = create(:tweet, user: @user)

          delete "/api/v1/tweets/#{@tweet.id}", headers: header_with_authentication(@user)
        end

        it 'should have returned the http status no content' do
          expect(response).to have_http_status(:no_content)
        end

        it 'should have deleted de tweet' do
          expect(Tweet.count).to eql(0)
        end
      end

      context 'when user is not the resrouce owner' do
        before do
          user = create(:user)
          tweet = create(:tweet)
          delete "/api/v1/tweets/#{tweet.id}", headers: header_with_authentication(user)
        end

        it 'should have returned the http status forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end

    end
  end

  describe 'PUT /api/v1/tweets/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :put, '/api/v1/tweets/-1'
    end

    context 'Authenticated' do
      before do
        @user = create(:user)
      end

      context 'when user is the resource owner' do
        before do
          tweet = create(:tweet, user: @user)
          @tweet_params = attributes_for(:tweet)
          put "/api/v1/tweets/#{tweet.id}", params: { tweet: @tweet_params }, headers: header_with_authentication(@user)
        end

        it 'should have returned the http status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should have returned the right updated tweet in json' do
          expect(json).to include_json(@tweet_params)
        end
      end

      context 'when user is not the resource owner' do
        before do
          tweet = create(:tweet)
          tweet_params = attributes_for(:tweet)

          put "/api/v1/tweets/#{tweet.id}", params: { tweet: tweet_params }, headers: header_with_authentication(@user)
        end

        it 'should have returned the http status forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end

    end
    
  end
end
