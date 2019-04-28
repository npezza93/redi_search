# frozen_string_literal: true

module RediSearch
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current[:searchkick_runtime] = value
    end

    def self.runtime
      Thread.current[:searchkick_runtime] ||= 0
    end

    def self.reset_runtime
      rt = runtime
      self.runtime = 0
      rt
    end

    def search(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload
      command =
        color("#{payload[:name]} (#{event.duration.round(1)}ms)", RED, true)

      debug "  #{command}  #{color(payload[:query].join(' '), BLUE, true)}"
    end
  end
end
