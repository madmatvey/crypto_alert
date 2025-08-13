require 'rails_helper'

RSpec.describe HelloWorker, type: :worker do
  it 'enqueues and performs the job' do
    expect { HelloWorker.perform_async('test') }.to change(Sidekiq::Queues['default'], :size).by(1)

    # Run inline to assert perform works
    Sidekiq::Testing.inline! do
      expect { HelloWorker.new.perform('test') }.not_to raise_error
    end
  end
end
