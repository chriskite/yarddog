class Source < ActiveRecord::Base
  has_attached_file :tgz
  validates_attachment :tgz, presence: true, 
                             content_type: {
                               content_type: "application/x-compressed"
                             },
                             size: { in: 0..20.megabytes }

  has_many :runs
end
