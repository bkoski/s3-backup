require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "s3-backup"
    gem.summary = %Q{Easy tar-based backups to S3, with backup rotation, cleanup helpers, and pre-/post-backup hooks.}
    gem.description = %Q{Easy tar-based backups to S3, with backup rotation, cleanup helpers, and pre-/post-backup hooks.}
    gem.email = "gems@benkoski.com"
    gem.homepage = "http://github.com/bkoski/s3-backup"
    gem.authors = ["Ben Koski"]
    
    gem.files += ["lib/s3-backup/base.rb"]
    
    gem.add_dependency "aws_credentials", ">= 0.6.0"
    gem.add_dependency "right_aws", "~> 2.0.0"
    
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "mocha", ">= 0"
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'hanna/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "s3-backup #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
