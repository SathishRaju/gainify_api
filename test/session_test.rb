require 'test_helper'

class SessionTest < Test::Unit::TestCase

  context "Session" do
    should "not be valid without a url" do
      session = GainifyAPI::Session.new(nil, "any-token")
      assert_not session.valid?
    end

    should "not be valid without token" do
      session = GainifyAPI::Session.new("testshop.mygainify.com")
      assert_not session.valid?
    end

    should "be valid with any token and any url" do
      session = GainifyAPI::Session.new("testshop.mygainify.com", "any-token")
      assert session.valid?
    end

    should "not raise error without params" do
      assert_nothing_raised do
        session = GainifyAPI::Session.new("testshop.mygainify.com", "any-token")
      end
    end

    should "raise error if params passed but signature omitted" do
      assert_raises(GainifyAPI::ValidationException) do
        session = GainifyAPI::Session.new("testshop.mygainify.com")
        session.request_token({'code' => 'any-code'})
      end
    end

    should "setup api_key and secret for all sessions" do
      GainifyAPI::Session.setup(:api_key => "My test key", :secret => "My test secret")
      assert_equal "My test key", GainifyAPI::Session.api_key
      assert_equal "My test secret", GainifyAPI::Session.secret
    end

    should "use 'https' protocol by default for all sessions" do
      assert_equal 'https', GainifyAPI::Session.protocol
    end

    should "#temp reset GainifyAPI::Base.site to original value" do

      GainifyAPI::Session.setup(:api_key => "key", :secret => "secret")
      session1 = GainifyAPI::Session.new('fakeshop.mygainify.com', 'token1')
      GainifyAPI::Base.activate_session(session1)

      GainifyAPI::Session.temp("testshop.mygainify.com", "any-token") {
        @assigned_site = GainifyAPI::Base.site
      }
      assert_equal 'https://testshop.mygainify.com/admin', @assigned_site.to_s
      assert_equal 'https://fakeshop.mygainify.com/admin', GainifyAPI::Base.site.to_s
    end

    should "create_permission_url returns correct url with single scope no redirect uri" do
      GainifyAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
      session = GainifyAPI::Session.new('http://localhost.mygainify.com')
      scope = ["write_products"]
      permission_url = session.create_permission_url(scope)
      assert_equal "https://localhost.mygainify.com/admin/oauth/authorize?client_id=My_test_key&scope=write_products", permission_url
    end

    should "create_permission_url returns correct url with single scope and redirect uri" do
      GainifyAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
      session = GainifyAPI::Session.new('http://localhost.mygainify.com')
      scope = ["write_products"]
      permission_url = session.create_permission_url(scope, "http://my_redirect_uri.com")
      assert_equal "https://localhost.mygainify.com/admin/oauth/authorize?client_id=My_test_key&scope=write_products&redirect_uri=http://my_redirect_uri.com", permission_url
    end

    should "create_permission_url returns correct url with dual scope no redirect uri" do
      GainifyAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
      session = GainifyAPI::Session.new('http://localhost.mygainify.com')
      scope = ["write_products","write_customers"]
      permission_url = session.create_permission_url(scope)
      assert_equal "https://localhost.mygainify.com/admin/oauth/authorize?client_id=My_test_key&scope=write_products,write_customers", permission_url
    end

    should "create_permission_url returns correct url with no scope no redirect uri" do
      GainifyAPI::Session.setup(:api_key => "My_test_key", :secret => "My test secret")
      session = GainifyAPI::Session.new('http://localhost.mygainify.com')
      scope = []
      permission_url = session.create_permission_url(scope)
      assert_equal "https://localhost.mygainify.com/admin/oauth/authorize?client_id=My_test_key&scope=", permission_url
    end

    should "raise exception if code invalid in request token" do
      GainifyAPI::Session.setup(:api_key => "My test key", :secret => "My test secret")
      session = GainifyAPI::Session.new('http://localhost.mygainify.com')
      fake nil, :url => 'https://localhost.mygainify.com/admin/oauth/access_token',:method => :post, :status => 404, :body => '{"error" : "invalid_request"}'
      assert_raises(GainifyAPI::ValidationException) do
        session.request_token(params={:code => "bad-code"})
      end
      assert_equal false, session.valid?
    end

    should "#temp reset GainifyAPI::Base.site to original value when using a non-standard port" do
      GainifyAPI::Session.setup(:api_key => "key", :secret => "secret")
      session1 = GainifyAPI::Session.new('fakeshop.mygainify.com:3000', 'token1')
      GainifyAPI::Base.activate_session(session1)

      GainifyAPI::Session.temp("testshop.mygainify.com", "any-token") {
        @assigned_site = GainifyAPI::Base.site
      }
      assert_equal 'https://testshop.mygainify.com/admin', @assigned_site.to_s
      assert_equal 'https://fakeshop.mygainify.com:3000/admin', GainifyAPI::Base.site.to_s
    end

    should "return site for session" do
      session = GainifyAPI::Session.new("testshop.mygainify.com", "any-token")
      assert_equal "https://testshop.mygainify.com/admin", session.site
    end

    should "return_token_if_signature_is_valid" do
      GainifyAPI::Session.secret = 'secret'
      params = {:code => 'any-code', :timestamp => Time.now}
      sorted_params = make_sorted_params(params)
      signature = Digest::MD5.hexdigest(GainifyAPI::Session.secret + sorted_params)
      fake nil, :url => 'https://testshop.mygainify.com/admin/oauth/access_token',:method => :post, :body => '{"access_token" : "any-token"}'
      session = GainifyAPI::Session.new("testshop.mygainify.com")
      token = session.request_token(params.merge(:signature => signature))
      assert_equal "any-token", token
    end

    should "raise error if signature does not match expected" do
      GainifyAPI::Session.secret = 'secret'
      params = {:code => "any-code", :timestamp => Time.now}
      sorted_params = make_sorted_params(params)
      signature = Digest::MD5.hexdigest(GainifyAPI::Session.secret + sorted_params)
      params[:foo] = 'world'
      assert_raises(GainifyAPI::ValidationException) do
        session = GainifyAPI::Session.new("testshop.mygainify.com")
        session.request_token(params.merge(:signature => signature))
      end
    end

    should "raise error if timestamp is too old" do
      GainifyAPI::Session.secret = 'secret'
      params = {:code => "any-code", :timestamp => Time.now - 2.days}
      sorted_params = make_sorted_params(params)
      signature = Digest::MD5.hexdigest(GainifyAPI::Session.secret + sorted_params)
      params[:foo] = 'world'
      assert_raises(GainifyAPI::ValidationException) do
        session = GainifyAPI::Session.new("testshop.mygainify.com")
        session.request_token(params.merge(:signature => signature))
      end
    end

    should "return true when the signature is valid and the keys of params are strings" do
      now = Time.now
      params = {"code" => "any-code", "timestamp" => now}
      sorted_params = make_sorted_params(params)
      signature = Digest::MD5.hexdigest(GainifyAPI::Session.secret + sorted_params)
      params = {"code" => "any-code", "timestamp" => now, "signature" => signature}

      assert_equal true, GainifyAPI::Session.validate_signature(params)
    end

    private

    def make_sorted_params(params)
      sorted_params = params.with_indifferent_access.except(:signature, :action, :controller).collect{|k,v|"#{k}=#{v}"}.sort.join
    end

  end
end
