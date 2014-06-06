# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :source do
    sha1 SPEC_SOURCE_SHA1 
    tgz { fixture_file_upload(Rails.root.join('spec', 'fixtures', SPEC_SOURCE_FILE), 'application/x-compressed') }
  end
end
