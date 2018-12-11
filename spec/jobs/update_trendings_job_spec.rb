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
end
