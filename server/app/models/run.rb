class Run < ActiveRecord::Base
  belongs_to :source
  belongs_to :user

  # for now, simply make a new instance; here would be the assignment logic
  after_create def assign
    server = EC2.instance.spin_up @instance_type
    @instance_id = server.id
  end
end
