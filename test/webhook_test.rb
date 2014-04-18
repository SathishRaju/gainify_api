require 'test_helper'

class WebhookTest < Test::Unit::TestCase
  test 'create should create a webhook' do
    fake 'webhooks', :method => :post, :status => 201, :body => load_fixture('webhook')
    webhook = GainifyAPI::Webhook.create(address: "http://www.yoloship.it/webhook", topic: "orders/create", format: "json")
    assert_equal "http://www.yoloship.it/webhook", webhook.address
  end

  test 'get should retrieve a webhook' do
    fake 'webhooks/123456', :method => :get, :status => 200, :body => load_fixture('webhook')
    webhook = GainifyAPI::Webhook.find(123456)
    assert_equal "http://www.yoloship.it/webhook", webhook.address
  end

  test 'find all should return all webhooks' do
    fake 'webhooks', :method => :get, :status => 200, :body => load_fixture('webhooks')
    webhook = GainifyAPI::Webhook.all
    assert_equal 123456, webhook.first.id
  end
end
