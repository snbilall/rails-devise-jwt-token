class SessionControllerController < ApplicationController
	skip_before_action :authenticate_request 

	def authenticate 
		command = AuthenticateUser.call(params[:email], params[:password]) 
		if command.success? 
			render json: { auth_token: command.result } 
		else 
			render json: { error: command.errors }, status: :unauthorized 
		end 
	end 

  
  # def create
  # 	user = User.where(email: params[:email]).first

  # 	if user.valid_password?(params[:password])
  # 		user.save
  # 		render json: user.as_json(only: [:id, :email, :authentication_token]), status: :created
  # 	else
  # 		head(:unauthorized)
  # 	end

  # end

  # def destroy
  # end
end
