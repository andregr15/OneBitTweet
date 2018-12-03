require 'rails_helper'

RSpec.describe "Api::V1::Likes", type: :request do
  describe "POST /api/v1/tweets/:id/like" do
    context 'with invalid credentials' do
      it_behaves_like :deny_without_authorization, :post, '/api/v1/tweets/-1/like'
    end

    context 'with valid credentials' do
      before do
        @user = create(:user)
        @tweet = create(:tweet)
        post "/api/v1/tweets/#{@tweet.id}/like", headers: header_with_authentication(@user)
      end

      it 'created the resource' do
        expect(response).to have_http_status(:created)
        expect(json['msg']).to eql('Liked with success')
      end

      it 'have the right tweet liked' do
        expect(@tweet.get_likes.size).to eql(1)
      end

      it 'have the right user' do
        expect(@user.liked? @tweet).to eql(true)
      end
    end
  end

  describe 'DELETE /api/v1/tweets/:id/like' do
    context 'with invalid credentials' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/tweets/-1/like'
    end

    context 'with valid credentials' do
      before do
        @user = create(:user)
        @tweet = create(:tweet)
        @user.likes @tweet
        delete "/api/v1/tweets/#{@tweet.id}/like", headers: header_with_authentication(@user)
      end

      it 'destroy the resource' do
        expect(response).to have_http_status(:no_content)
      end

      it 'have remove the right like' do
        expect(@tweet.get_likes.size).to eql(0)
      end

      it 'have remove the right user' do
        expect(@user.liked? @tweet).to eql(false)
      end
    end
  end
end
