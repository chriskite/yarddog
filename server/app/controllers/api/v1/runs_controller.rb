module Api
  module V1
    class RunsController < ApplicationController
      before_filter :restrict_access

      #
      # GET /runs
      # Return all in-progress runs
      #
      def index

      end

      #
      # GET /runs/:id
      # Return the single run specified by +id+
      #
      def show
        @run = Run.find(params[:id])
        render @run
      end

      #
      # POST /runs
      # Create a new run with the uploaded source code
      # Return the created run
      #
      def create
        if source_params[:sha1]
          # if the request contains a sha1 hash of a source tgz,
          # attempt to find the matching source object in the db.
          # if that fails, return an error.
          @source = Source.where(sha1: source_params[:sha1]).first
          if @source.nil?
            render json: {error: "No source with matching sha1"}, status: :bad_request
            return
          end
        elsif source_params[:git_url]
          # try to find an existing source with this git url
          @source = Source.where(git_url: source_params[:git_url]).first

          begin
            # if the git url wasn't already in a source, make a new one
            @source ||= Source.create!(git_url: source_params[:git_url])  
          rescue
            render json: {error: "Invalid Git Url"}, status: :bad_request
            return
          end
        else
          # make a new source object with the uploaded tgz
          @source = Source.create!(tgz: source_params[:source_tgz])
        end

        # TODO build source

        # attempt to create the run, and return any error to the client
        begin
          @run = Run.create!(run_params.merge(source: @source, user: @current_user))
        rescue
          render json: {error: $!.message}, status: :bad_request
          return
        end

        @run.delay.remote_assign
        render @run
      end

      #
      # DELETE /runs/:id
      # Attempt to kill and then delete run specified by +id+
      #
      def destroy
        Run.find(params[:id]).destroy
        # TODO give message to user
        # TODO decide if to shutdown machine
      end

      private

      def run_params
        params.permit(:instance_type)
      end

      def source_params
        params.permit(:sha1, :source_tgz, :git_url)
      end

    end
  end
end
