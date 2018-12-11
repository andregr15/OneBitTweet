require 'rails_helper'

RSpec.describe UpdateTrendingsJob, type: :job do
  describe '#perform_later' do
    it 'updates trending tweets' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UpdateTrendingsJob.perform_later
      }.to have_enqueued_job
    end

    it 'updates trending tweets in right queue' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UpdateTrendingsJob.perform_later
      }.to have_enqueued_job.on_queue('trendings')
    end
  end

  describe '#perform_now' do
    before do
      DataStore.redis.flushall
      DataStore.redis.set('#rails', 10)
      DataStore.redis.set('#ruby', 5)
      DataStore.redis.set('#sidekiq', 1)
      DataStore.redis.set('#docker', 50)
      UpdateTrendingsJob.perform_now
    end

    it 'saved the trending with the right values' do
      expect(Trending.last.hashtags).to eql([['#docker', '50'], ['#rails', '10'], ['#ruby', '5'], ['#sidekiq', '1']])
    end
  end
end
