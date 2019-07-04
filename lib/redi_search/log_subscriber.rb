# frozen_string_literal: true

module RediSearch
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current[:searchkick_runtime] = value
    end

    def self.runtime
      Thread.current[:searchkick_runtime] ||= 0
    end

    #:nocov:
    def self.reset_runtime
      rt = runtime
      self.runtime = 0
      rt
    end
    #:nocov:

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

    def spellcheck(event)
      log_command(event, YELLOW)
    end

    def explaincli(event)
      log_command(event, BLUE)
    end

    private

    def log_command(event, debug_color)
      self.class.runtime += event.duration
      return unless logger.debug?

      command = command_string(event)

      debug "  #{log_name(event)}  #{color(command, debug_color, true)}"
    end

    def log_name(event)
      color("#{event.payload[:name]} (#{event.duration.round(1)}ms)", RED, true)
    end

    def command_string(event)
      event.payload[:query].flatten.map.with_index do |arg, i|
        arg = "FT.#{arg}" if prepend_ft?(arg, i)
        arg = arg.inspect if inspect_arg?(event.payload, arg)
        arg
      end.join(" ")
    end

    def multiword?(string)
      !string.to_s.starts_with?(/\(-?@/) && string.to_s.split(/\s|\|/).size > 1
    end

    def prepend_ft?(arg, index)
      index.zero? && !multiword?(arg)
    end

    def inspect_arg?(payload, arg)
      multiword?(arg) && payload[:query].flatten.count > 1
    end
  end
end
