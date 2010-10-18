require 'right_aws'
require 'aws_credentials'
require 'fileutils'

require File.join(File.dirname(__FILE__), 's3-backup', 'base')

# To suppress "warning: peer certificate won't be verified in this SSL session" errors,
# borrowed from http://www.5dollarwhitebox.org/drupal/node/64
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end