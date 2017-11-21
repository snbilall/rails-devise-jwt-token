class ApplicationController < ActionController::API
	before_action :authenticate_request 
	attr_reader :current_user 

	def current_us
		render json: { user: @current_user.email }
	end

	private 
	def authenticate_request 
		@current_user = AuthorizeApiRequest.call(request.headers).result 
		render json: { error: 'Not Authorized' }, status: 401 unless @current_user 
	end

end
