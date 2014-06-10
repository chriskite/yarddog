class User < ActiveRecord::Base
  has_one :api_key, dependent: :destroy
  has_many :runs
  after_create :create_api_key

  validates :email, presence: true

  private

  def create_api_key
    ApiKey.create user: self
  end
end
