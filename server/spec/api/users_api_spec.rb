require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Users API' do

  before :each do
    FactoryGirl.create :user
  end

  # GET /users/:id
  it 'should return a single user' do
    expected_user = User.last
    api_get "users/#{expected_user.id}", {token: expected_user.api_key.token}
    expect(response.status).to eq(200)

    user = JSON.parse(response.body)
    expect(user['id']).to eq(expected_user.id)
    expect(user['email']).to eq(expected_user.email)
  end

end
