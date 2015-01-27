# Created by Dhanush Balachandran on 2014-Aug-15.
# Hacked up by Ron Conescu on 2015-Jan-22.
# Copyright (c) 2015 Y Media Labs. All rights reserved.
#
# To install Sinatra, type these at the command line:
# 	$ sudo gem install sinatra
# 	# sudo gem install thin
#
# ("thin" is the web server that Sinatra prefers.)
#
# Then to run this program, simply type
# 	$ ruby server_mockup.rb

require 'sinatra'
require 'json'
require 'fileutils'

disable :logging
set :bind, '0.0.0.0'
base_url_path = '/api/v1'
destination_directory = File.expand_path("~/Desktop/localLoggingServerOutput")
output_logging_filename = "output.txt"
file_content_divider = "----------"

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


#
# Listens for file uploads from our iOS apps.
# There's a centralized method there which
# calls this method, using the parameters
# it's expecting.
#
# To test this from curl, call:
#
# 		curl "http://localhost:4567/api/v1/upload/someName" -F filedata=@simpleFileToUpload.txt
# 		                                          ^^^^^^^^     ^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^
# 		                                             1             2               3
# With these components:
# 	1)	"somename" is anything you like.
# 	2)	"filedata" is required: the variable name we'll
# 		extract in this method.
# 	3)	"simpleFileToUpload.txt" is the file you want to
# 		upload.  Note the "@"; that's part of the 'curl'
# 		syntax.
#
# The results will be written to the file "output.txt"
# in a folder on your Mac desktop.
#
post "#{base_url_path}/upload/:filename" do
	FileUtils.mkdir_p(destination_directory)
	puts "#{params}"

	filename = File.join(destination_directory, output_logging_filename)
	datafile = params[:filedata]
	data = datafile[:tempfile].read
	
	File.open(filename, "a") { |theFile|
		theFile.write("#{file_content_divider}\n#{data}\n")
	}

	[200, {results: "wrote to #{filename}"}.to_json]
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
# Experimenting
#


# Yay!  Ok.  When I use curl to transmit a specific file (in my local directory) with the name "ronCustomFileContents", as follows:
# 		curl "http://localhost:4567/api/v1/ronTest/:whatever?one=1&two=2" -F ronCustomFileContents=@simpleFileToUpload.txt
#
# ...I can then extract it to a string with the code below:
# 		data = params[:ronCustomFileContents][:tempfile].read
#
# ...and when I use tail -f on the file "filename" (below),
# the results are indeed the contents of the file I wanted
# to upload.
#
post "#{base_url_path}/ronTest/:content" do
	FileUtils.mkdir_p(destination_directory)
	# puts "#{params}"
	
	filename = File.join(destination_directory, output_logging_filename)
	# data = params[:ronCustomFileContents]
	data = params[:ronCustomFileContents][:tempfile].read
	
	# FileUtils.append(datafile, filename)	
	# FileUtils.copy(datafile[:tempfile], filename)
	# file = File.open (filename, "a")	# append-only, creates if not there
	# File.write (filename, "test string", null, {mode: "a"})
	
	File.open(filename, "a") { |theFile|
		# theFile.write("here is some text. Did we get form data? #{request.env}\n")
		
		# envData = request.env
		# rackData = envData["rack"]
		# dataToPrint = envData
		# theFile.write("here is some text. Did we get form data? #{dataToPrint}\n")
		
		# theFile.write("here is some text. Did we get form data? #{params}\n")
		theFile.write("here is some text. Did we get form data? #{data}\n")
	}
	
	# "wrote to #{filename}\n"
	[200, {results: "wrote to #{filename}"}.to_json]
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
	[200, {error: "I didn't understand that GET request."}.to_json]
end

post "*" do
	[200, {error: "I didn't understand that POST command."}.to_json]
end


