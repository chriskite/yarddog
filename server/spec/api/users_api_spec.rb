require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Users API' do

  before :each do
    FactoryGirl.create :user
  end

  # GET /users/:id
  it "should return a single user" do
    expected_user = User.last
    api_get "users/#{expected_user.id}", {token: expected_user.api_key.token}
    expect(response.status).to eq(200)

    user = JSON.parse(response.body)
    expect(user['id']).to eq(expected_user.id)
    expect(user['email']).to eq(expected_user.email)
  end

  # POST /users
  describe "POST /users" do
    context "when an email is provided" do
      it "should create the specified user and return it, including token" do
        email = "test@example.com"
        api_post "users", {email: email, token: User.last.api_key.token}
        expect(response.status).to eq(200)

        user = JSON.parse(response.body)
        expect(user['id']).to be_kind_of(Fixnum)
        expect(user['email']).to eq(email)

        # validate token
        expect(user['token'].size).to eq(32)
        expect(user['token']).to eq(User.last.api_key.token)
      end
    end

    context "when no email is provided" do
      it "should return an error" do
        api_post "users", {token: User.last.api_key.token}
        expect(response.status).to eq(400)
      end
    end
  end

  # DELETE /users/:id
  it "should delete the user from the database"

end
