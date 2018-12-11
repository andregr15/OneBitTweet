require 'rails_helper'

RSpec.describe 'Api::V1::Trending', type: :request do
  describe '#trending' do
    context 'with hashtags' do
      context 'without redis' do
        before do
          @tweet = create(:tweet, body: '#ruby #ruby #ruby #rails #rails #rails #rails #rails #docker #vscode #vscode')
          AddHashtagsJob.perform_now(@tweet.body)
          UpdateTrendingsJob.perform_now
          get '/api/v1/trending'
        end
    
        it { expect(response).to have_http_status(:success) }
    
        it 'returned right trendings' do
          expect(json['hashtags']).to eql([['#rails', '5'], ['#ruby', '3'], ['#vscode', '2'], ['#docker', '1']])
        end
      end

      context 'using redis' do
        before do
          DataStore.redis.flushall
          DataStore.redis.set('#rails', 1)
          DataStore.redis.set('#ruby', 10)
          DataStore.redis.set('#docker', 5)
          DataStore.redis.set('#vscode', 50)

          UpdateTrendingsJob.perform_now
          get '/api/v1/trending'
        end

        it { expect(response).to have_http_status(:success) }

        it 'returned right trendings' do
          expect(json['hashtags']).to eql([['#vscode', '50'], ['#ruby', '10'], ['#docker', '5'], ['#rails', '1']])
        end
      end
    end

    context 'without hashtags' do
      before do
        DataStore.redis.flushall
        get '/api/v1/trending'
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to eql("null") }
    end
    
    
  end
end