require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Users API' do

  before :each do
    @user = FactoryGirl.create :user
    FactoryGirl.create :run, user: @user
  end

  # GET /runs/:id
  it 'should return a single run' do
    expected_run = Run.last
    api_get "runs/#{expected_run.id}", {token: @user.api_key.token}
    expect(response.status).to eq(200)

    run = JSON.parse(response.body)
    expect(run['id']).to eq(expected_run.id)
    expect(run['instance_type']).to eq(expected_run.instance_type)
  end

end
