class S3Backup

  # Array of files or paths to back up
  attr_accessor :files

  # Array of files that will be deleted post-backup, regardless of success
  attr_accessor :files_to_cleanup

  # Array of exclude patterns, these are passed to tar as <tt>--exclude</tt> flags
  attr_accessor :tar_excludes
  
  # Number of backups to keep on S3.  Defaults to 5.
  attr_accessor :copies_to_keep
  
  # Prefix for tarball, defaults to "backup".
  attr_accessor :backup_name
  
  # Name of bucket to push to, set on initialize.
  attr_reader :bucket_name
  
  # Initialize with the name of S3 bucket to push to
  def initialize(bucket_name)
    @files = []
    @files_to_cleanup = []
    @tar_excludes = []
    @copies_to_keep = 5
    @bucket_name = bucket_name
    @backup_name = 'backup'
    
    @s3 =  RightAws::S3.new(AWSCredentials.access_key, AWSCredentials.secret_access_key, :logger => Logger.new(nil))
  end

  # Called before backup runs.  Useful for dumping a database, or creating files
  # prior to tarball create.  As you create tmpfiles, you can push onto files_to_cleanup
  # to ensure post-backup cleanup.
  def before_backup &block
    @before_backup = block
  end

  # Called after backup runs.  Useful for restarting services.
  def after_backup &block
    @after_backup = block
  end

  # Runs the backup: creates tarball, pushes to s3, and rotates old backups.
  def run
    begin    
      @before_backup.call unless @before_backup.nil?
    
      create_tarball
      push_to_s3
      rotate_remote_backups
    
      @after_backup.call unless @after_backup.nil?
    ensure
      cleanup_files
    end
  end
  
  private
  # Name of the tarball created locally
  def tarball_name
    @tarbarll_name ||= "/tmp/#{backup_name}-#{Time.now.to_i}.tar.gz"
    @tarbarll_name
  end
  
  # Name of the file passed to tar -I containing files to back up
  def include_file_name
    tarball_name.gsub('.tar.gz','-includes.txt')
  end
  
  def create_tarball
    raise ArgumentError, "files to backup is empty!" if files.empty?
    
    write_include_file
    files_to_cleanup << include_file_name
    
    excludes = tar_excludes.collect { |e| "--exclude #{e}" }
    run_tar(%{#{excludes.join(" ")} --preserve -I #{include_file_name} -czf #{tarball_name}})
    
    files_to_cleanup << tarball_name
  end
  
  def write_include_file
    File.open(include_file_name, 'w') { |f| f.write(files.join("\n")) }
  end
  
  def run_tar params
    output = `tar #{params} 2>&1`
    raise "tar create failed with #{output}" if !$?.success?
  end
  
  def s3_bucket
    raise ArgumentError, "bucket_name must be set to run a backup!" if @bucket_name.nil?
    if @s3_bucket.nil?
      @s3_bucket = @s3.bucket(bucket_name)
      raise ArgumentError, "bucket #{bucket_name} not found!" if @s3_bucket.nil?
    end
    
    @s3_bucket
  end
  
  def push_to_s3
    s3_bucket.put(File.basename(tarball_name), File.open(tarball_name))
  end
  
  def rotate_remote_backups
    all_backups = s3_bucket.keys(:prefix => backup_name).sort_by { |k| k.name }.reverse
    if all_backups.length > copies_to_keep
      all_backups[copies_to_keep, all_backups.length - copies_to_keep].each { |k| k.delete }
    end
  end
  
  def cleanup_files
    files_to_cleanup.each { |f| FileUtils.rm_rf(f) }
  end
  
end