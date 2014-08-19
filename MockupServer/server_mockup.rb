# Created by Dhanush Balachandran on 8/15/14.
# Copyright (c) 2014 Y Media Labs. All rights reserved.

# Sinatra Instructions
#  In command line type
#  $ gem install sinatra
#  $ ruby server_mockup.rb

require 'sinatra'
require 'json'

#Errors
get '/api/test_fail' do
	[404, {message: 'Error'}.to_json]
end

post '/api/test_fail' do
	[404, {message: 'Error'}.to_json]
end

put '/api/test_fail' do
	[404, {message: 'Error'}.to_json]
end

get '/api/*' do
	[200, {endpoint: {hello: 'world'}}.to_json] 
end

post '/api/*' do 
	json = JSON.parse request.body.read
	[200, {endpoint: params, body: json }.to_json] 
end

put '/api/*' do 
	json = JSON.parse request.body.read
	[200, {endpoint: params, body: json }.to_json] 
end