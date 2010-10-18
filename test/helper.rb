require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 's3-backup'

class S3Backup
  # These methods become relevant in tests
  public :tarball_name, :include_file_name
end

class Test::Unit::TestCase
end
