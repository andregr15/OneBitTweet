require 'rails_helper'

RSpec.describe "Api::V1::Follows", type: :request do
  describe "CREATE /api/v1/users/:id/follow" do
    context 'with invalid credentials' do
      it_behaves_like :deny_without_authorization, :post, '/api/v1/users/1/follow'
    end

    context 'with valid credentials' do
      before do
        @user = create(:user)
        @other_user = create(:user)
        post "/api/v1/users/#{@other_user.id}/follow", headers: header_with_authentication(@user)
      end

      it 'creates the resource' do
        expect(response).to have_http_status(:created)
        expect(json['msg']).to eql('User followed with success')
      end

      it 'should have followed the right user' do
        expect(@user.following_users[0]).to eql(@other_user)
      end

      it 'should have incremented the follwing count' do
        expect(@user.following_users.count).to eql(1)
      end

      it 'should have the right follower' do
        expect(@other_user.followers[0]).to eql(@user)
      end

      it 'should have incremented the followers count' do
        expect(@other_user.followers.count).to eql(1)
      end

    end
  end

  describe 'DELETE /api/v1/users/:id/follow' do
    context 'with invalid credentials' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/users/-1/follow'
    end

    context 'with valid credentials' do
      before do
        @user = create(:user)
        @other_user = create(:user)
        @user.follow(@other_user)
        delete "/api/v1/users/#{@other_user.id}/follow", headers: header_with_authentication(@user)
      end

      it 'destroy the resource' do
        expect(response).to have_http_status(:success)
        expect(json['msg']).to eql('User unfollowed with success')
      end

      it 'should have unfollowed the right user' do
        expect(@user.following_users[0]).to eql(nil)
      end

      it 'should have decrement the following count' do
        expect(@user.following_users.count).to eql(0)
      end

      it 'should have remove the right follower' do
        expect(@other_user.followers[0]).to eql(nil)
      end

      it 'should have decremented the followers count' do
        expect(@other_user.followers.count).to eql(0)
      end

    end
  end
end
