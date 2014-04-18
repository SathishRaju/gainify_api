require 'test_helper'


class BaseTest < Test::Unit::TestCase

  def setup
    @session1 = GainifyAPI::Session.new('shop1.mygainify.com', 'token1')
    @session2 = GainifyAPI::Session.new('shop2.mygainify.com', 'token2')
  end

  def teardown
    clear_header('X-Custom')
  end

  test '#activate_session should set site and headers for given session' do
    GainifyAPI::Base.activate_session @session1

    assert_nil ActiveResource::Base.site
    assert_equal 'https://shop1.mygainify.com/admin', GainifyAPI::Base.site.to_s
    assert_equal 'https://shop1.mygainify.com/admin', GainifyAPI::Shop.site.to_s

    assert_nil ActiveResource::Base.headers['X-Gainify-Access-Token']
    assert_equal 'token1', GainifyAPI::Base.headers['X-Gainify-Access-Token']
    assert_equal 'token1', GainifyAPI::Shop.headers['X-Gainify-Access-Token']
  end

  test '#clear_session should clear site and headers from Base' do
    GainifyAPI::Base.activate_session @session1
    GainifyAPI::Base.clear_session

    assert_nil ActiveResource::Base.site
    assert_nil GainifyAPI::Base.site
    assert_nil GainifyAPI::Shop.site

    assert_nil ActiveResource::Base.headers['X-Gainify-Access-Token']
    assert_nil GainifyAPI::Base.headers['X-Gainify-Access-Token']
    assert_nil GainifyAPI::Shop.headers['X-Gainify-Access-Token']
  end

  test '#activate_session with one session, then clearing and activating with another session should send request to correct shop' do
    GainifyAPI::Base.activate_session @session1
    GainifyAPI::Base.clear_session
    GainifyAPI::Base.activate_session @session2

    assert_nil ActiveResource::Base.site
    assert_equal 'https://shop2.mygainify.com/admin', GainifyAPI::Base.site.to_s
    assert_equal 'https://shop2.mygainify.com/admin', GainifyAPI::Shop.site.to_s

    assert_nil ActiveResource::Base.headers['X-Gainify-Access-Token']
    assert_equal 'token2', GainifyAPI::Base.headers['X-Gainify-Access-Token']
    assert_equal 'token2', GainifyAPI::Shop.headers['X-Gainify-Access-Token']
  end

  test "#delete should send custom headers with request" do
    GainifyAPI::Base.activate_session @session1
    GainifyAPI::Base.headers['X-Custom'] = 'abc'
    GainifyAPI::Base.connection.expects(:delete).with('/admin/bases/1.json', has_entry('X-Custom', 'abc'))
    GainifyAPI::Base.delete "1"
  end

  test "#headers includes the User-Agent" do
    assert_not_includes ActiveResource::Base.headers.keys, 'User-Agent'
    assert_includes GainifyAPI::Base.headers.keys, 'User-Agent'
    thread = Thread.new do
      assert_includes GainifyAPI::Base.headers.keys, 'User-Agent'
    end
    thread.join
  end

  if ActiveResource::VERSION::MAJOR >= 4
    test "#headers propagates changes to subclasses" do
      GainifyAPI::Base.headers['X-Custom'] = "the value"
      assert_equal "the value", GainifyAPI::Base.headers['X-Custom']
      assert_equal "the value", GainifyAPI::Product.headers['X-Custom']
    end

    test "#headers clears changes to subclasses" do
      GainifyAPI::Base.headers['X-Custom'] = "the value"
      assert_equal "the value", GainifyAPI::Product.headers['X-Custom']
      GainifyAPI::Base.headers['X-Custom'] = nil
      assert_nil GainifyAPI::Product.headers['X-Custom']
    end
  end

  if ActiveResource::VERSION::MAJOR >= 4 && ActiveResource::VERSION::PRE == "threadsafe"
    test "#headers set in the main thread affect spawned threads" do
      GainifyAPI::Base.headers['X-Custom'] = "the value"
      Thread.new do
        assert_equal "the value", GainifyAPI::Base.headers['X-Custom']
      end.join
    end

    test "#headers set in spawned threads do not affect the main thread" do
      Thread.new do
        GainifyAPI::Base.headers['X-Custom'] = "the value"
      end.join
      assert_nil GainifyAPI::Base.headers['X-Custom']
    end
  end

  def clear_header(header)
    [ActiveResource::Base, GainifyAPI::Base, GainifyAPI::Product].each do |klass|
      klass.headers.delete(header)
    end
  end
end
