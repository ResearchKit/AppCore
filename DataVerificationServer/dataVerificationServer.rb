#
# DataVerificationServer.rb
# AppCore 
#
# Copyright (c) 2015 Apple Inc. All rights reserved. 
# 
# Listens for data emitted by the matching
# DataVerificationClient code in the research
# apps.
#
# Requires the Ruby "gems" called "sinatra" and
# "thin."  To get those, type these two commands
# in the Terminal:
# 	sudo gem install sinatra
# 	sudo gem install thin
#
# Then to run this program, simply type
# 	ruby dataVerificationServer.rb
#
# You can launch this from any directory.
#
# For more information, see the Confluence page
# about this:
#
# 		https://ymedialabs.atlassian.net/wiki/display/APPLE/How+to+see+the+data+we+send+to+Sage

require 'sinatra'
require 'json'
require 'fileutils'

# Sinatra (web server) setup
disable :logging
set :bind, '0.0.0.0'

# Our variables
base_url_path			= '/api/v1'
destination_directory	= File.expand_path("~/Desktop/dataVerificationFiles")
download_directory		= File.join(destination_directory, "downloads")
output_log_file_path	= File.join(destination_directory, "dataVerificationLog.txt")


#
# File Upload
#
# Listens for file uploads from our iOS apps.
# There's a centralized method there which
# calls this method, using the parameters
# I'm expecting.
#
# To test this from curl, call:
#
# 		curl "http://localhost:4567/api/v1/upload/someTextFile.txt" -F filedata=@someTextFile.txt
#
# where someTextFile.txt is any text file you like.
#
# The results will be written to
#
# 		~/Desktop/dataVerificationFiles/dataVerificationLog.txt
#
# i.e., a folder on your Mac desktop.
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


