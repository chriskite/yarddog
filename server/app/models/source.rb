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

  def fresh_tgz_path

  end

  private

  def create_sha1
    return unless !!tgz.queued_for_write[:original]
    self.sha1 = Digest::SHA1.file(tgz.queued_for_write[:original].path).hexdigest
  end
end
