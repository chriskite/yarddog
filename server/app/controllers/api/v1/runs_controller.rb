module Api
  module V1
    class RunsController < ApplicationController
      
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
        if run_params[:sha1]
          # if the request contains a sha1 hash of a source tgz,
          # attempt to fin the matching source object in the db.
          # if that fails, return an error.
          @source = Source.where(sha1: run_params[:sha1]).first
          if @source.nil?
            render json: {error: "No source with matching sha1"}, status: :bad_request
          end
        else
          # make a new source object with the uploaded tgz
          @source = Source.create(tgz: run_params[:source_tgz])
        end

        @run = Run.create(run_params)
        @run.source = @source
        @run.user = @current_user
        @run.save
      end

      #
      # DELETE /runs/:id
      # Attempt to kill and then delete run specified by +id+
      #
      def destroy

      end

      private

      def run_params
        params.require(:instance_type)
              .permit(:sha1, :source_tgz)
      end

    end
  end
end
