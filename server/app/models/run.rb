class Run < ActiveRecord::Base
  belongs_to :source
  belongs_to :user

  # for now, simply make a new instance; here would be the assignment logic
  before_save def assign
    if EC2.all.empty?
      server = EC2.create self.instance_type
    else
      server = EC2.all.first
    end
    self.instance_id = server.id
    #TODO upload image to server
  end

end
