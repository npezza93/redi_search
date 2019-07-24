# frozen_string_literal: true

require "active_support/log_subscriber"

module RediSearch
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current[:redi_search_runtime] = value
    end

    def self.runtime
      Thread.current[:redi_search_runtime] ||= 0
    end

    #:nocov:
    def self.reset_runtime
      rt = runtime
      self.runtime = 0
      rt
    end
    #:nocov:

    def action(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      command = command_string(event)
      debug_color = action_color(event.payload[:action])

      debug "  #{log_name(event)}  #{color(command, debug_color, true)}"
    end

    private

    def log_name(event)
      color("#{event.payload[:name]} (#{event.duration.round(1)}ms)", RED, true)
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    def action_color(action)
      case action.to_sym
      when :search, :spellcheck then YELLOW
      when :create, :add then GREEN
      when :drop, :del then RED
      when :get, :mget, :info then CYAN
      when :pipeline then MAGENTA
      when :explaincli then BLUE
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

    def command_string(event)
      event.payload[:query].flatten.map.with_index do |arg, i|
        arg = "FT.#{arg}" if prepend_ft?(arg, i)
        arg = arg.inspect if inspect_arg?(event.payload, arg)
        arg
      end.join(" ")
    end

    def multiword?(string)
      !string.to_s.start_with?(/\(-?@/) && string.to_s.split(/\s|\|/).size > 1
    end

    def prepend_ft?(arg, index)
      index.zero? && !multiword?(arg)
    end

    def inspect_arg?(payload, arg)
      multiword?(arg) && payload[:query].flatten.count > 1
    end
  end
end
