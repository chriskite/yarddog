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
        else
          # make a new source object with the uploaded tgz
          @source = Source.create!(tgz: source_params[:source_tgz])
        end

        # run_params is a ActionController::Parameters, which gets serialized strangely by delayed_job. 
        # Fix is to turn it into a plain hash with .to_h, which works.
        @run = Run.delay.create!(run_params.merge(source: @source, user: @current_user).to_h)
      end

      #
      # DELETE /runs/:id
      # Attempt to kill and then delete run specified by +id+
      #
      def destroy

      end

      private

      def run_params
        params.permit(:instance_type)
      end

      def source_params
        params.permit(:sha1, :source_tgz)
      end

    end
  end
end
