class Source < ActiveRecord::Base
  has_attached_file :tgz
  validates_attachment :tgz, presence: true,
                             content_type: {
                               content_type: "application/x-compressed"
                             },
                             size: { in: 0..20.megabytes }

  has_many :runs
  before_save :create_sha1

  private

  def create_sha1
    self.sha1 = Digest::SHA1.file(tgz.queued_for_write[:original].path).hexdigest
  end
end
