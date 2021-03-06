require 'test_helper'

class ProductTest < Test::Unit::TestCase
  def setup
    super

    fake "products/632910392", :body => load_fixture('product')
    @product = GainifyAPI::Product.find(632910392)
  end

  def test_add_metafields_to_product
    fake "products/632910392/metafields", :method => :post, :status => 201, :body => load_fixture('metafield')

    field = @product.add_metafield(GainifyAPI::Metafield.new(:namespace => "contact", :key => "email", :value => "123@example.com", :value_type => "string"))
    assert_equal ActiveSupport::JSON.decode('{"metafield":{"namespace":"contact","key":"email","value":"123@example.com","value_type":"string"}}'), ActiveSupport::JSON.decode(FakeWeb.last_request.body)
    assert !field.new_record?
    assert_equal "contact", field.namespace
    assert_equal "email", field.key
    assert_equal "123@example.com", field.value
  end

  def test_get_metafields_for_product
    fake "products/632910392/metafields", :body => load_fixture('metafields')

    metafields = @product.metafields

    assert_equal 2, metafields.length
    assert metafields.all?{|m| m.is_a?(GainifyAPI::Metafield)}
  end

  def test_update_loaded_variant
    fake "products/632910392/variants/808950810", :method => :put, :status => 200, :body => load_fixture('variant')

    variant = @product.variants.first
    variant.price = "0.50"
    variant.save
  end
end
