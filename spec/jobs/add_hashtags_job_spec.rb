require 'rails_helper'

RSpec.describe AddHashtagsJob, type: :job do
  describe '#perform_later' do
    it 'updates trending tweets' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        AddHashtagsJob.perform_later('teste')
      }.to have_enqueued_job
    end

    it 'updates trending tweets in right queue' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        AddHashtagsJob.perform_later('teste')
      }.to have_enqueued_job.on_queue('trendings')
    end
  end
end
