require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Runs API' do

  before :each do
    @user = FactoryGirl.create :user
  end

  describe "GET /runs/:id" do
    it "should return a single run" do
      expected_run = FactoryGirl.create :run, user: @user
      api_get "runs/#{expected_run.id}", {token: @user.api_key.token}
      expect(response.status).to eq(200)

      run = JSON.parse(response.body)
      expect(run['id']).to eq(expected_run.id)
      expect(run['instance_type']).to eq(expected_run.instance_type)
    end
  end

  describe "POST /runs" do
    context "when a sha1 is provided" do
      instance_type = "c3.xlarge"

      context "and a source already exists with that sha1" do
        it "should create a new run with the existing source" do
          source = FactoryGirl.create :source
          api_post "runs", {sha1: source.sha1, instance_type: instance_type, token: @user.api_key.token}
          expect(response.status).to eq(200)

          run = JSON.parse(response.body)
          expect(run['id']).to be_kind_of(Fixnum)
          expect(run['instance_type']).to eq(instance_type)
          expect(run['user']).to eq(@user.email)

          db_run = Run.last
          expect(db_run.source).to eq(source)
          expect(db_run.user).to eq(@user)
          expect(db_run.instance_type).to eq(instance_type)
        end
      end
      
      context "and no source exists with that sha1" do
        it "should return a 400 error"
      end
    end

    context "when no sha1 is provided and a source tgz is uploaded" do
      it "should create a new souce and run"
    end
  end

end
