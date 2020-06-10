# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

apartments_table = DB.from(:apartments)
feedback_table = DB.from(:feedback)
users_table = DB.from(:users)

# # read your API credentials from environment variables
# account_sid = ENV["TWILIO_ACCOUNT_SID"]
# auth_token = ENV["TWILIO_AUTH_TOKEN"]

# # set up a client to talk to the Twilio REST API
# client = Twilio::REST::Client.new(account_sid, auth_token)


# # send the SMS from your trial Twilio number to your verified non-Twilio number
# client.messages.create(
# from: "+133664595980", 
# to: "+16365790353",
# body: "Thank you for signing up with X Social Communities!"
# )


before do
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

# Home page
get "/" do
    @apartments = apartments_table.all
    view "home"
end

post "/" do
    @apartments = apartments_table.all
    view "home"
end

# Apartment Page
get "/apartments/:id" do
    @users_table = users_table
    @apartments = apartments_table.where(:id => params["id"]).to_a[0]
    results = Geocoder.search(@apartments[:address])
    @lat_long = results.first.coordinates.join(",")
    view "apartments"
end

# Form to create a new user
get "/users/new" do
    view "new_user"
end

# Receiving end of new user form
post "/users/create" do
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => params["password"],
                       :unit => params["unit"])
    puts users_table.inspect
    view "create_user"
end

# Form to login
get "/logins/new" do
    view "new_login"
end

# Feedback
get "/feedback" do
    @apartments = apartments_table.where(:id => params["id"]).to_a[0]
    view "feedback"
end

# Receiving end of new feedback form
post "/feedback/create" do
    feedback_table.insert(:name => params["name"],
                       :apartment => params["apartment"],
                       :unit => params["unit"],
                       :comments => params["feedback"])
    puts feedback_table.inspect
    view "create_feedback"
end

# Receiving end of login form
post "/logins/create" do
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        if user[:password] == password_entered
            session[:user_id] = user[:id]

            view "create_login"
        else
            view "create_login_failed"
        end
    else 
        view "create_login_failed"
    end
end


# Logout
get "/logout" do
    session[:user_id] = nil
    view "logout"
end