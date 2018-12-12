require 'rails_helper'

RSpec.describe 'Api::V1::Trending', type: :request do
  describe '#trending' do
    context 'with hashtags' do
      before do
        @trending = create(:trending)
        get '/api/v1/trending'
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns the right trending' do
        expect(json).to eql(JSON.parse(@trending.to_json))
      end
    end

    context 'without hashtags' do
      before do
        get '/api/v1/trending'
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to eql("null") }
    end

  end
end