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
      log_command(event, YELLOW)
    end

    def create(event)
      log_command(event, GREEN)
    end

    def drop(event)
      log_command(event, RED)
    end

    def add(event)
      log_command(event, GREEN)
    end

    def info(event)
      log_command(event, CYAN)
    end

    private

    def log_command(event, debug_color)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload
      command = "#{payload[:name]} (#{event.duration.round(1)}ms)"
      query = payload[:query].join(" ")

      debug "  #{color(command, RED, true)}  #{color(query, debug_color, true)}"
    end
  end
end
