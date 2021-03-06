require 'test_helper'

class RecurringApplicationChargeTest < Test::Unit::TestCase

  def test_recurring_application_charges_create
    fake "recurring_application_charges", :method => :post, :status => 201, :body => load_fixture('recurring_application_charge')

    charge = GainifyAPI::RecurringApplicationCharge.create(
      name: "Default Plan",
      price: 10.0,
      return_url: "http://test.com/confirm"
    )

    assert_equal 'http://apple.mygainify.com/admin/charges/654381177/confirm_recurring_application_charge?signature=BAhpBHkQASc%3D--419fc7424f8c290ac2b21b9004ed223e35b52164', charge.confirmation_url
  end

  def test_get_recurring_application_charges
    fake "recurring_application_charges/654381177", :method => :get, :status => 201, :body => load_fixture('recurring_application_charge')

    charge = GainifyAPI::RecurringApplicationCharge.find(654381177)

    assert_equal "Super Duper Plan", charge.name
  end

  def test_list_recurring_application_charges
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.find(:all)

    assert_equal "Super Mega Plan", charge.last.name
  end

  def test_list_since_recurring_application_charges
    fake "recurring_application_charges.json?since_id=64512345",:extension => false, :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.find(:all, :params => {:since_id => '64512345'})

    assert_equal "Super Mega Plan", charge.last.name
  end

  def test_list_fields_recurring_application_charges
    fake "recurring_application_charges.json?fields=name",:extension => false, :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.find(:all, :params => {:fields => 'name'})

    assert_equal "Super Mega Plan", charge.last.name
  end

  def test_pending_recurring_application_charge
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.pending

    assert_equal "Super Mega Plan2", charge.last.name
  end

  def test_cancelled_recurring_application_charge
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.cancelled

    assert_equal "Super Mega Plan3", charge.last.name
  end

  def test_accepted_recurring_application_charge
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.accepted

    assert_equal "Super Mega Plan4", charge.first.name
    assert_equal "Super Mega Plan", charge.last.name
  end

  def test_declined_recurring_application_charge
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')

    charge = GainifyAPI::RecurringApplicationCharge.declined

    assert_equal "Super Mega Plan5", charge.last.name
  end

  def test_activate_recurring_application_charge
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')
    fake "recurring_application_charges/455696199/activate", :method => :post, :status => 200, :body => "{}"

    charge = GainifyAPI::RecurringApplicationCharge.accepted

    assert charge.last.activate
  end

  def test_cancel_recurring_application_charge
    fake "recurring_application_charges", :method => :get, :status => 201, :body => load_fixture('recurring_application_charges')
    fake "recurring_application_charges/455696194", :method => :delete, :status => 200, :body => "{}"

    charge = GainifyAPI::RecurringApplicationCharge.current
    assert charge.cancel
  end

  def test_no_recurring_application_charge_found
    fake "recurring_application_charges", body: {recurring_application_charges: []}.to_json

    assert_equal 0, GainifyAPI::RecurringApplicationCharge.all.count
    assert_equal nil, GainifyAPI::RecurringApplicationCharge.current
    assert_equal [], GainifyAPI::RecurringApplicationCharge.pending
  end

end
