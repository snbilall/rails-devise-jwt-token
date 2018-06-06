RAILS TOKEN AUTH WİTH GEMS DEVISE AND JWT

first create rails app as api app like shown below (aşağıdaki kodla api uygulaması oluşturun)
```
rails new app_name --api
```
install gem devise from here: https://github.com/plataformatec/devise and create a User 
(devise gemini kurun ve User adında model oluşturun)

add gem 'jwt' and run bundle insall (jwt gemini ekleyin)

create 'lib/json_web_token.rb' and paste code below (yandaki dosyayı oluşturun ve aşağıdaki kodu yapıştırın)

```ruby
class JsonWebToken 
	class << self 
		def encode(payload, exp = 24.hours.from_now) 
			payload[:exp] = exp.to_i 
			JWT.encode(payload, Rails.application.secrets.secret_key_base) 
		end 
		def decode(token) body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0] 
			HashWithIndifferentAccess.new body 
		rescue 
			nil 
		end 
	end 
end
```
add code below to Application method inside 'config/application.rb' 
(yukardaki dosyayı oluşturun ve aşağıdaki kodu yapıştırın)
```ruby
config.autoload_paths << Rails.root.join('lib')

add gem 'simple_command' and run bundle insall
```
create app/commands/authenticate_user.rb and paste code below 
(yukardaki dosyayı oluşturun ve aşağıdaki kodu yapıştırın)
```ruby
class AuthenticateUser 
	prepend SimpleCommand 
	def initialize(email, password) 
		@email = email 
		@password = password 
	end 
	def call 
		JsonWebToken.encode(user_id: user.id) if user 
	end 

	private 
	
	attr_accessor :email, :password 

	def user 
		user = User.find_by_email(email) 
		return user if user && user.valid_password?(password) 
		errors.add :user_authentication, 'invalid credentials' 
		nil 
	end 
end
```
create app/commands/authorize_api_request.rb and paste code below 
(yukardaki dosyayı oluşturun ve aşağıdaki kodu yapıştırın)
```ruby
class AuthorizeApiRequest 
	prepend SimpleCommand 
	def initialize(headers = {}) 
		@headers = headers 
	end 
	def call 
		user 
	end 
	private 
	attr_reader :headers 
	def user 
		@user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token 
		@user || errors.add(:token, 'Invalid token') && nil 
	end 

	def decoded_auth_token 
		@decoded_auth_token ||= JsonWebToken.decode(http_auth_header) 
	end 
	def http_auth_header 
		if headers['Authorization'].present? 
			return headers['Authorization'].split(' ').last 
		else 
			errors.add(:token, 'Missing token') 
		end 
		nil 
	end 
end
```
run command in console and create a session_controller(aşağıdaki komutla session_contolleri oluşturun)
```
rails g controller session_controller authenticate
```
and paste below code inside authenticate method (ve aşağıdaki kodu authenticate metoduna yapıştırın)
```ruby
command = AuthenticateUser.call(params[:email], params[:password]) 
if command.success? 
	render json: { auth_token: command.result } 
else 
	render json: { error: command.errors }, status: :unauthorized 
end 
```
add the line to routes.rb (routes.rb ye aşağıdakini ekleyin)
```ruby
post 'session_controller/authenticate'
```
paste codes below to ApplicationController (aşağıdaki kodu ApplicationController içine yapıştırın)
```ruby
before_action :authenticate_request 
attr_reader :current_user 

def current_us #this func returns current user due to access-token(bu fonksiyon access tokenın sahibini verir)
	render json: { user: @current_user.email }
end

private 
def authenticate_request 
	@current_user = AuthorizeApiRequest.call(request.headers).result 
	render json: { error: 'Not Authorized' }, status: 401 unless @current_user 
end
```
add the line to routes.rb (routes.rb ye aşağıdakini ekleyin)
```ruby
post get 'application/current_us'
```
USAGE (KULLANIMI):

rails db:seed creates two users. (bu kod iki kullanıcı oluşturur)

run the server typing rails s (serveri çalıştırın)
```
curl -H "Content-Type: application/json" -X POST -d '{"email":"a@b","password":"123456"}' http://localhost:3000/session_controller/create 
```
yukarıdaki istek kullanıcının id, email ve auth token niteliklerini döndürür
request written above returns user id, email and auth token
```
curl -H "Authorization: paste_access_token_here" http://localhost:3000/application/current_us
```
yukarıdaki istek token verilen kullanıcıyı döndürür
request above returns current user due to given token.

Update: simple_comand => jwt

```ruby
