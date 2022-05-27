class ApplicationJob < ActiveJob::Base
  include Sidekiq::Status::Worker
  sidekiq_options(retry: false)

  class << self
    def schedule(v = nil)
      @schedule ||= v
    end

    def human_schedule
      return 'Not scheduled' if schedule.blank?

      Cronex::ExpressionDescriptor.new(schedule.partition(' ').last).description
    end

    def timeout(v = nil)
      @timeout ||= v || 15.minutes
    end
  end

  delegate :timeout, to: :class

  def perform(*args)
    Timeout.timeout(timeout) do
      call(*args)
    end
  end
end
