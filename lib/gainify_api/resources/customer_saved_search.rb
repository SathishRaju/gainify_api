require 'gainify_api/resources/customer'

module GainifyAPI
  class CustomerSavedSearch < Base
    def customers(params = {})
      Customer.find(:all, :params => params.merge({ :customer_saved_search_id => self.id }))
    end
  end
end
