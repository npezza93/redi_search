# frozen_string_literal: true

require "test_helper"
require "active_support/log_subscriber/test_helper"

module RediSearch
  class LogSubscriberTest < Minitest::Test
    Event = Struct.new(:duration, :payload)

    include ActiveSupport::LogSubscriber::TestHelper

    def setup
      super
      @log_subscriber = LogSubscriber.new
      RediSearch::LogSubscriber.attach_to :redi_search
      ActiveSupport::LogSubscriber.colorize_logging = true
    end

    def teardown
      super
      ActiveSupport::LogSubscriber.log_subscribers.clear
    end

    def test_search
      instrument("search", query: %w(SEARCH foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[33mFT.SEARCH foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_spellcheck
      instrument("spellcheck", query: %w(SPELLCHECK foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[33mFT.SPELLCHECK foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_create
      instrument("create", query: %w(CREATE foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[32mFT.CREATE foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_hset
      instrument("hset", query: %w(HSET foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[32mHSET foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_dropindex
      instrument("dropindex", query: %w(DROPINDEX foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[31mFT.DROPINDEX foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_del
      instrument("del", query: %w(DEL foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[31mDEL foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_hgetall
      instrument("hgetall", query: %w(HGETALL foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[36mHGETALL foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_pipeline
      instrument("pipeline", query: %w(PIPELINE))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[35mFT.PIPELINE\e[0m",
        @logger.logged(:debug).last
      )
    end

    def test_explaincli
      instrument("explaincli", query: %w(EXPLAINCLI SEARCH foo))

      assert_equal(
        "\e[1m\e[31mRediSearch (0.9ms)\e[0m  \e[1m\e[34mFT.EXPLAINCLI " \
        "SEARCH foo\e[0m",
        @logger.logged(:debug).last
      )
    end

    private

    def instrument(action, payload)
      @log_subscriber.action(Event.new(
        0.9, name: "RediSearch", action: action, **payload
      ))
    end
  end
end
