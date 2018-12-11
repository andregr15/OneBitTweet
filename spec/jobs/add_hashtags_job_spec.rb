require 'rails_helper'

RSpec.describe AddHashtagsJob, type: :job do
  describe '#perform_later' do
    it 'add hashtags on redis' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        AddHashtagsJob.perform_later('teste')
      }.to have_enqueued_job
    end

    it 'enqueued in right queue' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        AddHashtagsJob.perform_later('teste')
      }.to have_enqueued_job.on_queue('trendings')
    end
  end

  describe '#perform_now' do
    before do
      DataStore.redis.flushall
      @tweet = create(:tweet, body: '#ruby, #rails, #ruby, #rails, #rails')
      AddHashtagsJob.perform_now(@tweet.body)
    end

    it 'added the hashtags' do
      expect(DataStore.redis.get('#ruby').to_i).to eql(2)
      expect(DataStore.redis.get('#rails').to_i).to eql(3)
    end
  end
end
