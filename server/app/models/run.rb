class Run < ActiveRecord::Base
  belongs_to :source
  belongs_to :user

  # for now, simply make a new instance; here would be the assignment logic
  before_save :assign, unless: Proc.new { source.nil? }

  def assign
    if EC2.all.empty?
      server = EC2.create instance_type
    else
      server = EC2.all.first
    end
    instance_id = server.id
    server.upload_image source.tgz.path
  end

end
