class Run < ActiveRecord::Base
  belongs_to :source
  belongs_to :user

  # for now, simply make a new instance; here would be the assignment logic
  def remote_assign
    raise "No user" if user.nil?
    raise "No source" if source.nil?

    if EC2.all.empty?
      server = EC2.create instance_type
    else
      server = EC2.all.first
    end
    instance_id = server.id
    image_id = server.upload_image source.fresh_tgz_path
  end

  before_destroy :remote_destroy
  def remote_destroy
    EC2.find(instance_id).kill(container_id, image_id)
  end

end
