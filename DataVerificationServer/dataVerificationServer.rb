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


#
# Modules we're using.
#
require 'sinatra'
require 'json'
require 'fileutils'
require "open3"


#
# Sinatra (web server) setup.
#
disable :logging
set :bind, '0.0.0.0'


#
# Our variables.
#
base_url_path					= '/api/v1'
destination_directory			= File.expand_path("~/Desktop/dataVerificationFiles")
text_file_extensions_i_can_read	= [".json", ".txt", ".csv"]


#
# Section dividers, and unique names for files and folders.
#
# For the available time-and-date specifiers, see:
# 		http://www.ruby-doc.org/core-2.2.0/Time.html#method-i-strftime
#
FILE_DIVIDER_CHAR				= "-"
SECTION_DIVIDER_CHAR			= "-"
SECTION_DIVIDER_FORMAT			= "---------- New files arrived on %A, %Y-%m-%d at %H:%M:%S %Z ----------"
DOWNLOAD_FOLDER_NAME_FORMAT		= "files_%Y-%m-%d_%H-%M-%S-%3N"
STARTUP_MESSAGE_DIVIDER_CHAR	= "="
STARTUP_MESSAGE_FORMAT			= "========== DataValidationServer starting up: %A, %Y-%m-%d at %H:%M:%S %Z =========="
OUTPUT_FILE_NAME				= "dataVerificationServerLog.txt"


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
# The results will be written to:
#
# 		~/Desktop/dataVerificationFiles/dataVerificationLog.txt
#
# i.e., a folder on your Mac desktop.
#

post "#{base_url_path}/upload/:filename" do
	
	#
	# Setup
	#
	FileUtils.mkdir_p( destination_directory )
	
	
	#
	# Folder for these new files.
	#
	directory_error_message = nil;
	download_directory = Utils.unique_folder_name_inside_parent_directory( destination_directory )
	
	if Dir.exists?( download_directory ) then
		directory_error_message =	"WARNING: Couldn't create unique download directory!\n"		\
									"         You may see lots of files appearing in the\n" \
									"         same directory.  Please show this message\n"	\
									"         to whoever is maintaining this Ruby script."
	end
	
	FileUtils.mkdir_p( download_directory )
	

	#
	# Copy from temp directory
	#
	zip_file_base_name	= params[ :filename ]
	downloadedZipFile	= File.join( download_directory, zip_file_base_name )
	datafile			= params[ :filedata ]
	FileUtils.copy( datafile[ :tempfile ], downloadedZipFile )
	
	
	#
	# Unzip
	#
	
	#
	# We can also do this:
	# 		processId = spawn( "unzip -o #{downloadedZipFile}" )	# -o == overwrite without asking
	# 		Process.wait processId								# make it synchronous
	#
	# ...but that doesn't give me the stdout, and lets
	# the stdout appear immediately.
	#

	unzip_output = "";
	Dir.chdir( download_directory )
	Open3.popen2e( "unzip -o #{downloadedZipFile}" ) { |stdin, stdout_and_stderr, thread_to_wait_for|
		process_id = thread_to_wait_for.pid			# pid of the started process.
		exit_status = thread_to_wait_for.value		# Process::Status object returned.
		
		# We can also extract the contents of a stream
		# with read():
		# 		unzip_output = stdout_and_stderr.read
		
		stdout_and_stderr.each { |line|
			
			# indent it.  We'll shove "unzip"'s output
			# in the middle of ours.
			unzip_output << "> #{line}"
		}
	}
	
	
	#
	# Analyze files
	#
	
	file_counter = 0
	content_file_list = ""
	content_file_contents = ""
	
	Dir.glob( "#{download_directory}/*" ) do |file_path|
		this_base_name = File.basename( file_path )

		if (this_base_name != zip_file_base_name) then
			file_counter = file_counter + 1
			
			content_file_list << "#{file_counter}.  #{this_base_name}\n"
			
			if text_file_extensions_i_can_read.include?( File.extname( file_path )) then
				file_pointer = File.open( file_path, "r")
				file_contents = file_pointer.read
				file_pointer.close
				
				basename = File.basename( file_path )
				file_name = "#{file_counter}. #{basename}"
				file_divider = FILE_DIVIDER_CHAR * (file_name.length + 1)	# +1 == it overhangs by 1 char.
				
				content_file_contents << "#{file_divider}\n#{file_name}\n#{file_divider}\n#{file_contents}\n\n"
			end
		end
	end
	
	
	#
	# Report what we just got
	#
	
	content = "\n\n\n#{Utils.section_divider}\n"
	content << "Got file     : #{zip_file_base_name}\n"
	content << "Unzipping to : #{download_directory}/\n\n"
	# content << "#{unzip_output}\n"		# for now, just suppress the unzip output.  I may revive this.
	content << "It contains these files:\n"
	content << content_file_list
	content << "\n#{directory_error_message}\n" if directory_error_message != nil
	content << "\nHere are the files I can read.\n\n"
	content << content_file_contents

	puts content


	
	#
	# Copy it to a file in the new directory
	#
	
	output_file_path = File.join( download_directory, OUTPUT_FILE_NAME )
	
	File.open(output_file_path, "a") { |output_file|
		output_file.write content
	}
	
	
	# Return value (different from above?)
	# 	[200, {results: "wrote to #{downloadedZipFile}"}.to_json]		# this is how to return JSON to the client
	200
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



#
# Gradually evolving tools for this file.
# ...and re-learning Ruby, after a many-year break.
#
class Utils
	
	def self.unique_folder_name_inside_parent_directory( parent_folder_name )
		
		error_checking_counter = 0		# to make sure I'm not doing something silly.
		
		unique_folder_name = generate_unique_folder_name()
		result = File.join( parent_folder_name, unique_folder_name)
	
		while  File.exists?( result ) && error_checking_counter < 100  do
			sleep 0.01		# I just need a unique filename
			unique_folder_name = generate_unique_folder_name()
			result = File.join( parent_folder_name, unique_folder_name)
			error_checking_counter += 1
		end
		
		result
	end
	
	def self.generate_unique_folder_name
		Time.now.localtime.strftime( DOWNLOAD_FOLDER_NAME_FORMAT )
	end
	
	def self.section_divider
		time_string = Time.now.localtime.strftime( SECTION_DIVIDER_FORMAT )
		visual_divider = SECTION_DIVIDER_CHAR * time_string.length
		divider = "#{visual_divider}\n#{time_string}\n#{visual_divider}" 
		
		# To return a value, put it on a line by itself:
		divider
	end
	
	def self.startup_message
		time_string = Time.now.localtime.strftime( STARTUP_MESSAGE_FORMAT )
		visual_divider = STARTUP_MESSAGE_DIVIDER_CHAR * time_string.length
		message = "#{visual_divider}\n#{time_string}\n#{visual_divider}"
		
		# To return a value, put it on a line by itself:
		message
	end
	
end


#
# Startup message
#
# I'm putting this at the end of the file
# because I don't yet know Ruby or Sinatra
# enough to ask Sinatra to tell me, "please
# do this when you've finisehd starting up."
# So I have to do it physically after
# defining my startup_message() method.
#

puts "\n\n\n#{Utils.startup_message}\n\n"
