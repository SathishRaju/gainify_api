module GainifyAPI
  module Countable
    def count(options = {})
      Integer(get(:count, options))
    end
  end
end
