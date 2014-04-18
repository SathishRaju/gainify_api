require 'test_helper'

class LimitsTest < Test::Unit::TestCase
  def setup
    GainifyAPI::Base.site = "test.mygainify.com"
    @header_hash = {'http_x_gainify_shop_api_call_limit' => '100/300'}
    GainifyAPI::Base.connection.expects(:response).at_least(0).returns(@header_hash)
  end

  context "Limits" do
    should "fetch limit total" do
      assert_equal(299, GainifyAPI.credit_limit(:shop))
    end

    should "fetch used calls" do
      assert_equal(100, GainifyAPI.credit_used(:shop))
    end

    should "calculate remaining calls" do
      assert_equal(199, GainifyAPI.credit_left)
    end

    should "flag maxed out credits" do
      assert !GainifyAPI.maxed?
      @header_hash = {'http_x_gainify_shop_api_call_limit' => '299/300'}
      GainifyAPI::Base.connection.expects(:response).at_least(1).returns(@header_hash)
      assert GainifyAPI.maxed?
    end

    should "raise error when header doesn't exist" do
      @header_hash = {}
      GainifyAPI::Base.connection.expects(:response).at_least(1).returns(@header_hash)
      assert_raise GainifyAPI::Limits::LimitUnavailable do
        GainifyAPI.credit_left
      end
    end
  end
end
