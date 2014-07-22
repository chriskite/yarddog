class Run < ActiveRecord::Base
  belongs_to :source
  belongs_to :user

  # for now, simply make a new instance; here would be the assignment logic
  after_create :remote_assign, unless: Proc.new { source.nil? || user.nil? }
  def remote_assign
    if EC2.all.empty?
      server = EC2.create instance_type
    else
      server = EC2.all.first
    end
    instance_id = server.id
    image_id = server.upload_image source.tgz.path
  end

  before_destroy :remote_destroy
  def remote_destroy
    EC2.find(instance_id).kill(container_id, image_id)
  end

end
