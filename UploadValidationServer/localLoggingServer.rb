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

# Sinatra (web server) setup
disable :logging
set :bind, '0.0.0.0'

# My variables
base_url_path			= '/api/v1'
destination_directory	= File.expand_path("~/Desktop/uploadValidationServerOutput")
download_directory		= File.join(destination_directory, "downloads")
output_log_file_path	= File.join(destination_directory, "output.txt")



#
# File Upload
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
	
	#
	# Setup
	#
	FileUtils.mkdir_p(destination_directory)
	FileUtils.mkdir_p(download_directory)
	
	# Echo to the console.
	puts "\n----------\nInput parameters:\n     #{params}"


	#
	# Delete existing files, if any
	#
	# Purposely waiting 'til now to delete the previous
	# files, so that I can error-check each file after
	# uploading it.  (The more standard way might be
	# to delete the file after using it, below.)
	#
	
	Dir.foreach(download_directory) do |someFilePath|
		
		# File.delete(someFile)		# permissions problems
		processId = spawn("rm #{someFilePath}")
		Process.wait processId
		
	end
	

	#
	# Copy from temp directory
	#
	baseName			= params[:filename]
	downloadedZipFile	= File.join(download_directory, baseName)
	datafile			= params[:filedata]
	FileUtils.copy(datafile[:tempfile], downloadedZipFile)
	
	
	#
	# Unzip
	#

	Dir.chdir(download_directory)
	processId = spawn("unzip -o #{downloadedZipFile}")		# -o == overwrite without asking
	Process.wait processId									# make it synchronous
	
	
	#
	# append content to output file
	#
	
	File.open(output_log_file_path, "a") { |output_log_file|
		output_log_file.write(
			"\n======== New batch of files ========\n"	\
			"These JSON files are located here:\n"		\
			"     #{download_directory}\n"				\
			"\n"										\
			"They'll be deleted when you upload the next batch.\n" 
		)
	}
	
	Dir.glob("#{download_directory}/*.json") do |jsonFile|
		
		thisFile = File.open(jsonFile, "r")
		thisFileContents = thisFile.read
		
		File.open(output_log_file_path, "a") { |output_log_file|
			baseName = File.basename(jsonFile)
			output_log_file.write( "\n#{baseName}:\n#{thisFileContents}\n" )
		}
	end
	

	# echo to stdout (?)
	puts "\n     wrote to #{downloadedZipFile}"
	
	# Return value (different from above?)
	[200, {results: "wrote to #{downloadedZipFile}"}.to_json]
end



#
# Catchall handlers.
# 
# This works:  catches all requests that didn't
# meet one of the above criteria.  ORDER MATTERS:
# if this rule goes first, the other rules don't
# run.
#

get "*" do
	[200, {error: "I didn't understand that GET request."}.to_json]
end

post "*" do
	[200, {error: "I didn't understand that POST command."}.to_json]
end


