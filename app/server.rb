require 'sinatra/base'
require 'sinatra/partial'
require 'data_mapper'
require 'rack-flash'
require './lib/link'
require './lib/tag'
require './lib/user'
require_relative './data_mapper_setup'
require_relative './helpers/helpers'

class BookmarkManager < Sinatra::Base
  register Sinatra::Partial

  set :views,  Proc.new { File.join(root, "..", "views")  }
  set :public_folder, Proc.new { File.join(root, "..", "public_folder") }
  set :partial_template_engine, :erb

  enable :sessions
  set :session_secret, 'super secret'
  use Rack::Flash
  use Rack::MethodOverride

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(" ").map do |tag|
      Tag.first_or_create(:text => tag)
    end

    Link.create(:url => url, :title => title, :tags => tags)

    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user =User.new
    erb :"users/new"
  end

  post '/users' do
  @user = User.new(:email => params[:email],
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/new"
    end
  end

  get '/sessions/new' do
    erb :"sessions/new"
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ["The email or password is incorrect"]
      erb :"sessions/new"
    end
  end

  delete '/sessions' do
    session.clear
    flash[:notice] = 'Good bye!'
    redirect to('/')
  end

  get '/password_reset' do
    erb :"users/password_reset"
  end

  post '/password_reset' do
    email = params[:email]
    user = User.first(:email => email)
    token = user.generate_password_token
    stamp = user.generate_new_time_stamp
    user.update(password_token: token, password_token_timestamp: stamp)
    p User.first(:email => email)
    flash[:notice] = "Email sent to #{email}!"
    redirect to('/')
  end


  get '/users/reset_password/:token' do
    @token = params[:token]
    erb :'users/set_new_password'
  end

  get '/users/set_new_password' do
    erb :"users/set_new_password"
  end

  post '/users/set_new_password' do
    @token = params[:password_token]
    user = User.first(:password_token => @token)
    user.update(password: params[:password], password_confirmation: params[:password_confirmation])
    if user.save
      session[:user_id] = user.id
      redirect to('/sessions/new')
    else
      flash[:errors] = user.errors.full_messages
      erb :"users/set_new_password"
    end
  end

  get '/links/new' do
    erb :"links/new"
  end

  post '/links/new' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(" ").map{|tag| Tag.first_or_create(:text => tag)}
    Link.create(:url => url, :title => title, :tags => tags)
    redirect to('/')
  end

  helpers Helpers

end
