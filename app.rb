require 'sinatra'
require 'sinatra/activerecord'
require 'active_record'
require 'faker'
#require 'sinatra/reloader'
enable :sessions
set :sessions, :expire_after => 3600

set :database, "sqlite3:woofers.sqlite3"
#ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
#FOR THOSE OF YOU JUST JOINING US, THIS ENVIRONMENT VARIABLE THING ALLOWS HEROKU TO FILL IN THE BLANK AND USE POSTGRES. FOR LOCAL RUNNING OF THE APP, THE SIMPLEST THING TO DO IS CHANGE WHICH LINES ARE COMMENTED OUT HERE. THERE IS LIKELY A MORE ELEGANY SOLUTION SUCH AS PUTTING THE DATABASE_URL IN THE COMMAND LINE WHEN RUNNING THE SERVER.
#Figure out a way to set development and production for these two
#Heroku struggle
get '/' do
  @user = session[:name]
  erb :index
end

get '/admin' do
  #user = User.find_by(email: email)
  #if session[:user] == "admin@admin.com"
    @users = User.all
    erb :admin
  #else
  #  redirect '/'
  #end
end

i = 2
post '/login' do

  email = params['email'] #from the form input on login.erb
  submitted_password = params['password']
  user = User.find_by(email: email)
  if !user && i > 0
    redirect '/signup'
  elsif
    submitted_password == user.password
    session[:user] = user.id
    session[:name] = user.fname
    session[:lname] = user.lname
    session[:email] = user.email
    session[:birthday] = user.birthday
    session[:password] = user.password
    session[:date_joined] = user.created_at
    #session[:message] = "Email entered: + #{email}" #passes message to the GET request to which the browser will be redirected later (next).
    #redirect "/login?email=#{email}"
    redirect '/account'
  elsif i > 0
    session[:message] = "Please check the spelling of your email, password, or both, and try again. Attempts remaining #{i}"
    i -= 1
    redirect '/login'
  else
    @message = "MAXIMUM LOGIN ATTEMPTS EXCEEDED."
    #or as a classmate suggested, "Lookie here, user..."
  end
end

get '/login' do
  @message = session[:message]#takes message from the session and puts it into the instance variable @message. Doing so enables us to put it into our view.
  @email = params['email']
  erb :login
end

get '/signup' do
  erb :signup
end

post '/signup' do
  user = User.new(
    fname: params['first_name'],
    lname: params['last_name'],
    email: params['email'],
    password: params['password'],
    birthday: params['birth_date']
    )
  @name = params['first_name']
  user.save
  redirect '/account'
end

get '/account' do
  if session[:user]
    #@user = User.find(session[:user_id]) - what would this do?
    @userposts = Post.select {
    |q| q.author == session[:name]
    }
    erb :account
  else
    redirect '/'
  end
end

post '/account' do
  user = User.find(session[:user])
  if params['password'] == user.password
  User.destroy(session[:user])
  session[:user] = nil
  redirect '/'
  session[:message] = "Your account has been deleted"
  else
    session[:message] = "Retry password"
    redirect '/account'
  end
end

post '/posts' do
    author = session[:name]
  post = Post.new(
    title: params['post_title'],
    body: params['post_body'],
    author: author
    )
  #@post = params['first_name']
  if post.title != '' && post.body != ''
  post.save
  else
  session[:message] = "Post title and body can't be blank!"
  end
  @posts = Post.all
  erb :posts
end

get '/posts' do
  @posts = Post.all
  erb :posts
end

get '/friendposts' do
  @friendposts = Post.select {
    |q| q.author == search_name
  }
end
get '/myposts' do
  @user = session[:name]
  @myposts = Post.select {
  |q| q.author == session[:name]
  }
  erb :myposts
end

get '/logout' do
  session[:user] = nil
  p 'User has logged out'
  erb :logout
end

get'/about_us' do
  erb :about_us
end

get '/sponsors' do
  erb :sponsors
end

get '/woof' do
  erb :woof
end

get '/resources' do
  erb :resources
end

not_found do
  status 404
  erb :fourohfour
end


get '/logout' do
  erb :logout
end

require './models'

=begin
Recycle for later - displays the same url '/posts' differently based on whether there is a user logged in or not

get '/posts' do
  if session[:user]
    erb :posts_loggedin #has the ability to submit posts, shows published posts
  else
    erb :posts_loggedout #shows publised posts
  end
end
=end
