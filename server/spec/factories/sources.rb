# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :source do
    sha1 "83bfab7560e562641cc4d403946d7c8fe189c62d"
    tgz { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'source.tgz'), 'application/x-compressed') }
  end
end
