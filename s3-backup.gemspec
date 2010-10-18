# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{s3-backup}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Koski"]
  s.date = %q{2010-10-17}
  s.description = %q{Easy tar-based backups to S3, with backup rotation, cleanup helpers, and pre-/post-backup hooks.}
  s.email = %q{gems@benkoski.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/s3-backup.rb",
     "lib/s3-backup/base.rb",
     "test/helper.rb"
  ]
  s.homepage = %q{http://github.com/bkoski/s3-backup}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Easy tar-based backups to S3, with backup rotation, cleanup helpers, and pre-/post-backup hooks.}
  s.test_files = [
    "test/base_test.rb",
     "test/helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<aws_credentials>, [">= 0.6.0"])
      s.add_runtime_dependency(%q<right_aws>, ["~> 2.0.0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<aws_credentials>, [">= 0.6.0"])
      s.add_dependency(%q<right_aws>, ["~> 2.0.0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<aws_credentials>, [">= 0.6.0"])
    s.add_dependency(%q<right_aws>, ["~> 2.0.0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end

