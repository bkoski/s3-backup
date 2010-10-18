require 'helper'

class BaseTest < Test::Unit::TestCase
    
  def setup
    @b = S3Backup.new('test')
    @b.files = ['/tmp/test1.txt']
  end
  
  context "callbacks" do
    setup do
      stub_io_methods
    end
  
    should "call before_backup block before backup is run" do
      s = sequence('backup')

      before_mock = mock()
      before_mock.expects(:test_cmd).in_sequence(s)
      @b.before_backup { before_mock.test_cmd }

      @b.expects(:create_tarball).in_sequence(s)
      
      @b.run
    end
  
    should "call after_backup block after backup is run" do
      s = sequence('backup')
      
      @b.expects(:push_to_s3).in_sequence(s)
      
      after_mock = mock()
      after_mock.expects(:test_cmd).in_sequence(s)
      @b.after_backup { after_mock.test_cmd }

      @b.run
    end
  end
  
  context "cleanup" do
    setup do
      stub_io_methods
    end
    
    should "remove everything specified in files_to_delete on success" do
      @b.files_to_cleanup << '/tmp/testtmpfile.txt'
      FileUtils.expects(:rm_rf).with('/tmp/testtmpfile.txt')
      @b.run
    end
    
    should "remove everything specified in files_to_delete even if an exception was raised" do
      @b.files_to_cleanup << '/tmp/testtmpfile.txt'
      FileUtils.expects(:rm_rf).with('/tmp/testtmpfile.txt')
      @b.stubs(:create_tarball).raises('test error')
      @b.run rescue nil
    end
    
    should "remove local tarfile" do
      FileUtils.expects(:rm_rf).with(@b.tarball_name)
      @b.run
    end
    
    should "remove local includes file" do
      FileUtils.expects(:rm_rf).with(@b.include_file_name)
      @b.run
    end
  end
  
  context "tar file" do
    
    setup do
      stub_io_methods(:run_tar, :rotate_remote_backups)
            
      @tarball_mock = mock()
      File.stubs(:open).with(@b.tarball_name).returns(@tarball_mock)
      
      @include_file_mock = mock()
      @include_file_mock.stubs(:write)
      File.stubs(:open).with(@b.include_file_name, 'w').yields(@include_file_mock)      
    end
    
    context "naming" do
      should "default to backup" do
        @b.expects(:run_tar).with(regexp_matches(/backup-\d+.tar.gz$/))
        @b.run
      end
      
      should "include backup_name if specified" do
        @b = S3Backup.new('test')
        
        @b.files = ['/tmp/test1.txt']
        @b.backup_name = 'app_data'
        
        File.stubs(:open).with(@b.include_file_name, 'w').yields(@include_file_mock)
        File.stubs(:open).with(anything).returns(mock())
        
        @b.expects(:run_tar).with(regexp_matches(/app_data-\d+.tar.gz$/))
        @b.run
      end
    end

    should "include all files named in files" do
      @include_file_mock.expects(:write).with(@b.files.join("\n"))
      @b.expects(:run_tar).with(regexp_matches(/-I #{@b.include_file_name}/))
      @b.run
    end
    
    should "exclude tar_excludes" do
      @b.tar_excludes = ['*.log','*.txt']
      @b.expects(:run_tar).with(regexp_matches(/--exclude \*.log --exclude \*.txt/))
      @b.run
    end
    
    should "be run with --perserve" do
      @b.expects(:run_tar).with(regexp_matches(/--preserve /))
      @b.run
    end
    
    should "be pushed to s3" do
      @s3_bucket.expects(:put).with(File.basename(@b.tarball_name), @tarball_mock)
      @b.run
    end
  end
  
  context "rotation" do
    setup do
      stub_io_methods(:run_tar, :write_include_file, :push_to_s3)
    end
    
    should "not remove anything if total count is < copies_to_keep" do
      mock_keys = [mock(),mock()]
      mock_keys.each_with_index do |k,i|
        k.stubs(:name).returns(i.to_s)
        k.expects(:delete).never()
      end
      
      @s3_bucket.stubs(:keys).with(:prefix => @b.backup_name).returns(mock_keys)
      @b.run
    end
    
    should "remove oldest files if total count is > copies_to_keep" do
      mock_keys = [mock(:name => 'file-299'),mock(:name => 'file-300'),mock(:name => 'file-301'),mock(:name => 'file-302'),mock(:name => 'file-303')]
      mock_keys[0,@b.copies_to_keep].each { |k| k.expects(:delete).never() }
      
      extra_keys = [mock(:name => 'file-100'),mock(:name => 'file-102')]
      extra_keys.each { |k| k.expects(:delete) }
      mock_keys += extra_keys
      
      @s3_bucket.stubs(:keys).with(:prefix => @b.backup_name).returns(mock_keys)
      @b.run
    end
  end
  
  private
  def stub_io_methods *methods
    methods = [:run_tar, :write_include_file, :push_to_s3, :rotate_remote_backups] if methods.empty?
    methods.each { |io| S3Backup.any_instance.stubs(io) }
    @s3_bucket = mock()
    @s3_bucket.stubs(:put)
    S3Backup.any_instance.stubs(:s3_bucket).returns(@s3_bucket)
    FileUtils.stubs(:rm_rf)
  end
  
end