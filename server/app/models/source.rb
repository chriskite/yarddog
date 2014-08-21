class Source < ActiveRecord::Base
  GIT_URL_REGEX = %r{((git|ssh|http(s)?)|(git@[\w.]+))(:(//)?)([\w.@\:/-~]+)(.git)(/)?}

  has_attached_file :tgz
  validates :git_url, format: {with: GIT_URL_REGEX}, allow_nil: true
  validates_attachment :tgz, content_type: {
                               content_type: [
                                   "application/x-compressed",
                                   "application/gzip",
                               ]
                             },
                             size: { in: 0..20.megabytes }

  has_many :runs
  before_save :create_sha1

  #
  # If this source was an uploaded tgz, just return the path
  # If it's a git repo. clone/checkout and tgz it up
  #
  def fresh_tgz_path
    if !!git_url
      # clone/checkout and tgz the repo
      git_clone! if !Dir.exists?(git_checkout_path)
      git_pull!
      return make_git_tgz!
    else
      return tgz
    end
  end

  private

  def create_sha1
    return unless !!tgz.queued_for_write[:original]
    self.sha1 = Digest::SHA1.file(tgz.queued_for_write[:original].path).hexdigest
  end

  # 
  # The local filesystem path to the checkout path for this source
  #
  def git_checkout_path
    File.join(Rails.root, 'repos', self.id)
  end

  #
  # Clone self.git_url to the local filesystem
  #
  def git_clone!
    `git clone #{git_url} #{git_checkout_path}`
  end

  #
  # Pull master of the checked out git repo 
  #
  def git_pull!
    `cd #{git_checkout_path} && git fetch origin && git pull origin master`
  end

  #
  # Tar and gzip the git repo, and return the path of the tgz
  #
  def make_git_tgz!
    tar_name = File.join(Rails.root, 'repos', self.id + '.tar')
    tgz_name = tar_name + '.gz'

    # remove any existing tar/tgz for this repo
    [tar_name, tgz_name].each do |file|
      File.unlink(file) if File.exists?(file)
    end

    unless system "tar -c -f '#{tar_name}' '#{git_checkout_path}' 2>/dev/null"
      raise "Could not make tar in ‘#{tar_name}’: child exited with status #{$?}"
    end
    unless system "gzip -nk #{tar_name}"
      raise "Could not gzip ‘#{tar_name}’ into ‘#{tgz_name}’: child exited with status #{$?}"
    end

    return tgz_name
  end
end
