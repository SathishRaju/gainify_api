require 'test_helper'

class TransactionTest < Test::Unit::TestCase
  def setup
    fake "orders/450789469/transactions/389404469", :method => :get, :body => load_fixture('transaction')
  end

  context "Transaction" do
    context "#find" do
      should "find a specific transaction" do
        transaction = GainifyAPI::Transaction.find(389404469, :params => {:order_id => 450789469})
        assert_equal "409.94", transaction.amount
      end
    end
  end
end
