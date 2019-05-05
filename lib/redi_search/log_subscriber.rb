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

    def pipeline(event)
      log_command(event, MAGENTA)
    end

    def get(event)
      log_command(event, CYAN)
    end

    def mget(event)
      log_command(event, CYAN)
    end

    def del(event)
      log_command(event, RED)
    end

    private

    def log_command(event, debug_color)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload
      name = "#{payload[:name]} (#{event.duration.round(1)}ms)"
      command = command_string(payload)

      debug "  #{color(name, RED, true)}  #{color(command, debug_color, true)}"
    end

    def command_string(payload)
      payload[:query].flatten.tap do |query|
        query.each_with_index do |arg, i|
          if i.zero? && !multiword?(arg)
            query[i] = arg.dup.prepend "FT."
          end
          query[i] = arg.inspect if multiword?(arg) && query.count > 1
        end
      end.join(" ")
    end

    def multiword?(string)
      string.to_s.split.size > 1
    end
  end
end
