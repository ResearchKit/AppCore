# Created by Dhanush Balachandran on 8/15/14.
# Copyright (c) 2014 Y Media Labs. All rights reserved.

# Sinatra Instructions
#  In command line type
#  $ gem install sinatra
#  $ ruby server_mockup.rb

require 'sinatra'
require 'json'
require 'pry'

require 'fileutils'

base_path = '/api/v1'
#Errors
get "#{base_path}/test_fail" do
	[404, {message: 'Error'}.to_json]
end

post "#{base_path}/test_fail" do
	[404, {message: 'Error'}.to_json]
end

put "#{base_path}/test_fail" do
	[404, {message: 'Error'}.to_json]
end

#Maintenance
get "#{base_path}/server_maintenance" do
	[503, {message: 'Server Under Maintenance'}.to_json]
end

#File Upload
post "#{base_path}/upload/:filename" do
	  binding.pry
	  userdir = "/tmp/upload_files"
	  FileUtils.mkdir_p(userdir)
	  puts "#{params}"
	  filename = File.join(userdir, params[:filename])
	  datafile = params[:filedata]
	  FileUtils.copy(datafile[:tempfile], filename)
	  "wrote to #{filename}\n"
	  200
end

#Authentication
post "#{base_path}/auth/signUp" do
	200
end

post "#{base_path}/auth/signIn" do
	json = JSON.parse request.body.read
	[200, {username: json[:username], sessionToken: 'sessionToken', consented: true, authenticated: true}.to_json]
end

#Catch All
get "#{base_path}/*" do
	[200, {endpoint: {hello: 'world'}}.to_json] 
end

post "#{base_path}/*" do 
	json = JSON.parse request.body.read
	[200, {endpoint: params, body: json }.to_json] 
end

put "#{base_path}/*" do 
	json = JSON.parse request.body.read
	[200, {endpoint: params, body: json }.to_json] 
end