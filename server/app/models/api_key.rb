class ApiKey < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user, :key
  before_create :generate_key

  private

  def generate_key
    begin
      self.key = SecureRandom.hex.to_s
    end while self.class.exists?(key: key)
  end
end
