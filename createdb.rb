# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :apartments do
  primary_key :id
  String :title
  String :address
end

DB.create_table! :feedback do
  primary_key :id
  String :name
  String :email
  String :apartment
  String :unit
  String :comments, text: true
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
  String :unit
end

# Insert initial (seed) data
apartments_table = DB.from(:apartments)

apartments_table.insert(title: "X Denver", 
                    address: "3100 Inca Street, Denver, CO 80202")

apartments_table.insert(title: "X Logan Square", 
                    address: "2211 North Milwaukee Avenue, Chicago, IL 60647")

apartments_table.insert(title: "X Chicago", 
                    address: "710 West 14th Street, Chicago, IL 60607")

apartments_table.insert(title: "X Tampa", 
                    address: "719 N Florida Avenue, Tampa, FL 33602")
