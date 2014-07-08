module Api
  module V1
    class UsersController < ApplicationController
      before_filter :restrict_access

      def index

      end

      def create
        @user = User.create(user_params)
        unless @user.valid?
          render json: {error: "Could not create user"}, status: :bad_request
          return
        end

        render "_new_user"
      end

      def show
        @user = User.find(params[:id])
        render @user
      end

      private

      def user_params
        params.permit(:email)
      end

    end
  end
end
