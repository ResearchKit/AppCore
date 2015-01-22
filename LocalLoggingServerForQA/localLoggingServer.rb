# Created by Dhanush Balachandran on 2014-Aug-15.
# Hacked up by Ron Conescu on 2015-Jan-22.
# Copyright (c) 2015 Y Media Labs. All rights reserved.
#
# To install Sinatra, type this at the command line:
# 	$ sudo gem install sinatra
#
# Then to run this program, simply type
# 	$ ruby server_mockup.rb

require 'sinatra'
require 'json'
require 'fileutils'

disable :logging
set :bind, '0.0.0.0'
base_url_path = '/api/v1'
destination_directory = "~/Desktop/localLoggingServerOutput"
output_logging_filename = "output.txt"

#
# Testing errors (?)
#

get "#{base_url_path}/test_fail" do
	[404, {message: 'Error'}.to_json]
end

post "#{base_url_path}/test_fail" do
	[404, {message: 'Error'}.to_json]
end

put "#{base_url_path}/test_fail" do
	[404, {message: 'Error'}.to_json]
end


#
# Maintenance
# 

get "#{base_url_path}/server_maintenance" do
	[503, {message: 'Server Under Maintenance'}.to_json]
end


#
# File Upload
#

post "#{base_url_path}/upload/:filename" do
	FileUtils.mkdir_p(destination_directory)
	puts "#{params}"
	filename = File.join(destination_directory, params[:filename])
	datafile = params[:filedata]
	FileUtils.copy(datafile[:tempfile], filename)
	"wrote to #{filename}\n"
	200
end


#
# Authentication
#

post "#{base_url_path}/auth/signUp" do
	200
end

post "#{base_url_path}/auth/signIn" do
	json = JSON.parse request.body.read
	[200, { username: 		json[:username],	\
			sessionToken: 	'sessionToken',		\
			consented: 		true,				\
			authenticated: 	true				\
		  }.to_json]
end


#
# Catch All
#

get "#{base_url_path}/*" do
	[200, {endpoint: {hello: 'world'}}.to_json] 
end

post "#{base_url_path}/*" do 
	json = JSON.parse request.body.read
	puts json["log"].to_s.colorize(:cyan)
	[200, {endpoint: params, body: json }.to_json] 
end

put "#{base_url_path}/*" do 
	json = JSON.parse request.body.read
	[200, {endpoint: params, body: json }.to_json] 
end

# This works:  catches all requests that didn't
# meet one of the above criteria.  ORDER MATTERS:
# if this rule goes first, the other rules don't
# run.
get "*" do
	[200, {error: "I didn't understand that command."}.to_json]
end


#
# Experimenting
#

# Doesn't work yet.
get "#{base_url_path}/testWrite/:content" do
	FileUtils.mkdir_p(destination_directory)
	puts "#{params}"
	filename = File.join(destination_directory, output_logging_filename)
	datafile = params[:content]
	FileUtils.append(datafile[:tempfile], filename)
	"wrote to #{filename}\n"
	200
end





