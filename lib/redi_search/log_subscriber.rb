# frozen_string_literal: true

require "active_support/version"
require "active_support/log_subscriber"
if ActiveSupport::VERSION::MAJOR > 6
  require "active_support/isolated_execution_state"
end

module RediSearch
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current[:redi_search_runtime] = value
    end

    def self.runtime
      Thread.current[:redi_search_runtime] ||= 0
    end

    # :nocov:
    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end
    # :nocov:

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

    # rubocop:disable Metrics/MethodLength
    def action_color(action)
      case action.to_sym
      when :search, :spellcheck, :aggregate then YELLOW
      when :create, :hset then GREEN
      when :dropindex, :del then RED
      when :hgetall, :info then CYAN
      when :pipeline then MAGENTA
      when :explaincli then BLUE
      end
    end
    # rubocop:enable Metrics/MethodLength

    def command_string(event)
      event.payload[:query].flatten.map.with_index do |arg, i|
        arg = "FT.#{arg}" if prepend_ft?(arg, i)
        arg = arg.inspect if inspect_arg?(event.payload, arg)
        arg = "  #{arg}"  if event.payload[:inside_pipeline]
        arg
      end.join(" ")
    end

    def multiword?(string)
      !string.to_s.start_with?(/\(-?@/) && string.to_s.split(/\s|\|/).size > 1
    end

    def prepend_ft?(arg, index)
      index.zero? && !multiword?(arg) && %w(HSET HGETALL DEL).exclude?(arg.to_s)
    end

    def inspect_arg?(payload, arg)
      multiword?(arg) && payload[:query].flatten.count > 1
    end
  end
end
