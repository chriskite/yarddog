require 'spec_helper'
require 'api/api_helper'
require 'fakeweb'
require 'timecop'

describe 'Runs API' do

  before :each do
    @user = FactoryGirl.create :user
  end

  describe "DELETE /runs/:id" do
    it "should delete the specified run from the database"

    context "when the run is in progress" do
      it "should attempt to kill the run"
    end
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
    instance_type = "c3.xlarge"

    context "when a sha1 is provided" do
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
        it "should return a 400 error" do
          api_post "runs", {sha1: "foo", instance_type: instance_type, token: @user.api_key.token}
          expect(response.status).to eq(400)
        end
      end
    end

    context "when no sha1 is provided and a source tgz is uploaded" do
      it "should create a new souce and run" do
        file = fixture_file_upload('source.tgz', 'application/x-compressed')
        api_post "runs", {source_tgz: file, instance_type: instance_type, token: @user.api_key.token}
        expect(response.status).to eq(200)

        run = JSON.parse(response.body)
        expect(run['id']).to be_kind_of(Fixnum)
        expect(run['instance_type']).to eq(instance_type)
        expect(run['user']).to eq(@user.email)

        # run should be correct in db
        db_run = Run.last
        expect(db_run.user).to eq(@user)
        expect(db_run.instance_type).to eq(instance_type)

        # new source should have been created
        new_source = db_run.source
        expect(new_source).to be_kind_of(Source)
        expect(new_source.sha1).to eq(SPEC_SOURCE_SHA1)
        expect(File.read(new_source.tgz.path)).to eq(File.read(Rails.root.join('spec', 'fixtures', SPEC_SOURCE_FILE)))
      end
    end
  end

end
