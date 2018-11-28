require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe "Api::V1::Users", type: :request do
  describe 'GET /api/v1/users/:id' do
    context 'when user exists' do
      let(:user) { create(:user) }
      let(:following_number) { Random.rand(9) }
      let(:followers_number) { Random.rand(9) }
      let(:tweet_number)     { Random.rand(9) }

      before do
        followers_number.times { create(:user).follow(user) }
        following_number.times { user.follow(create(:user)) }
        tweet_number.times     { create(:tweet, user: user) }

        get "/api/v1/users/#{user.id}"
      end

      it { expect(response).to have_http_status(:success) }

      it 'should returns a valid user in json' do
        expect(json).to eql(serialized(Api::V1::UserSerializer, user))
      end

      it 'should returns the right followers number' do
        expect(json['followers_count']).to eql(followers_number)
      end

      it 'should returns the right following number' do
        expect(json['following_count']).to eql(following_number)
      end

      it 'sould returns the right tweet number' do
        expect(json['tweets_count']).to eql(tweet_number)
      end
    end

    context 'when user do not exists' do 
      let(:user_id) { -1 }
      before { get "/api/v1/users/#{user_id}" }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'GET /api/v1/users/current' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :get, '/api/v1/users/current'
    end

    context 'Authenticated' do
      let(:user) { create(:user) }
      let(:following_number) { Random.rand(9) }
      let(:followers_number) { Random.rand(9) }
      let(:tweet_number)     { Random.rand(9) }

      before do
        followers_number.times { create(:user).follow(user) }
        following_number.times { user.follow(create(:user)) }
        tweet_number.times     { create(:tweet, user: user) }

        get '/api/v1/users/current', headers: header_with_authentication(user)
      end

      it { expect(response).to have_http_status(:success) }

      it 'should returns a valid user in json' do
        expect(json).to eql(serialized(Api:V1:UserSerializer, user))
      end

      it 'should returns the right number of followers' do
        expect(json['followers_count']).to eql(followers_number)
      end

      it 'should returns the right number of followings' do
        expect(json['followings_count']).to eql(following_number)
      end

      it 'should returns the right number of tweets' do
        expect(json['tweet_count']).to eql(tweet_number)
      end
    end 
  end

  describe 'DELETE /api/v1/users/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/users/-1'
    end

    context 'Authenticated' do
      context 'when user exists' do

        context 'when user is the owner of the resource' do
          before do 
            @user = create(:user)
            delete "/api/v1/users/#{@user.id}", headers: header_with_authentication(@user)
          end

          it 'should have returned no content http status' do
            expect_status(:no_content)
          end

          it 'should have deleted the user' do
            expect(User.count).to eq(0)
          end
        end

        context 'when user is not the owner of the resource' do
          before do
            user = create(:user)
            other_user = create(:user)

            delete "/api/v1/users/#{other_user.id}", headers: header_with_authentication(@user)
          end

          it 'should have returned forbidden http status' do
            expect_status(:forbidden)
          end
        end
      end

      context 'when user do not exists' do
        before do
          user = create(:user)
          user_id = -1
          delete "/api/v1/users/#{user_id}", headers: header_with_authentication(@user)
        end

        it 'should have returned not found http status' do
          expect_status(:not_found)
        end
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'With valid params' do
      before do
        @user_params = attributes_for(:user)
        post '/api/v1/users/', params: { user: @user_params }
      end

      it 'should have returned the http status created' do
        expect_response(:created)
      end

      it 'should have returned the right user in json' do
        expect(json).to include_json(user_params.except(:password))
      end

      it 'should have created the user' do
        expect(User.count).to eql(1)
      end

    end

    context 'With invalid params' do
      before do
        user_params = { foo: :bar}
        post '/api/v1/users', params: { user: user_params }
      end

      it 'should have returned the http status unprocessable_entity' do
        expect_response(:unprocessable_entity)
      end
    end

  end

  describe 'PUT /api/v1/users/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :put, '/api/v1/users/-1'
    end

    context 'Authenticated' do
      context 'when user is the owner of the resource' do
        context 'with valid params' do
          before do
            user = create(:user)
            @user_params = attributes_for(:user)

            put "/api/v1/users/#{user.id}", params: { user: @user_params }, headers: header_with_authentication(user)
          end

          it 'should have returned the http status success' do
            expect_response(:success)
          end

          it 'should have returned the json with the user updated' do
            expect(json).to include_json(@user_params.except(:password))
          end
        end

        context 'with invalid params' do
          before do
            user = create(:user)
            user_params = { foo: :bar }
            put "/api/v1/users/#{user.id}", params: { user: user_params }, headers: header_with_authentication(user)
          end

          it 'should have returned the http status unprocessable entity' do
            expect_status(:unprocessable_entity)
          end

        end
      end

      context 'when user is not the owner of the resource' do
        before do
          user = create(:user)
          other_user = create(:user)
          user_params = attributes_for(:user)

          put "/api/v1/users/#{other_user.id}", params: { user: user_params }, headers: header_with_authentication(user)
        end

        it 'should have returnet the http status forbidden' do
          expect_status(:forbidden)
        end
      end
    end
  end

end
