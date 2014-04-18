module GainifyAPI
  class Variant < Base
    include Metafields
    include DisablePrefixCheck

    conditional_prefix :product
  end
end
