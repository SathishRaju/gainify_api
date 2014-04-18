$:.unshift File.dirname(__FILE__)

require 'active_resource'
require 'active_support/core_ext/class/attribute_accessors'
require 'digest/md5'
require 'base64'
require 'active_resource/connection_ext'
require 'active_resource/detailed_log_subscriber'
require 'gainify_api/limits'
require 'gainify_api/json_format'
require 'active_resource/json_errors'
require 'active_resource/disable_prefix_check'
require 'active_resource/base_ext'
require 'active_resource/to_query'

module gainifyAPI
  include Limits
end

require 'gainify_api/events'
require 'gainify_api/metafields'
require 'gainify_api/countable'
require 'gainify_api/resources'
require 'gainify_api/session'
