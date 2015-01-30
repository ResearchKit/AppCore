------------
Tracking what works.
------------

Sinatra help files:  http://www.sinatrarb.com/intro.html
Accessing the Request object:  http://www.sinatrarb.com/intro.html#Accessing%20the%20Request%20Object

using curl to post a file with a specified name: http://stackoverflow.com/questions/3007253/send-post-xml-file-using-curl-command-line




------------
The ReadMe file, in progress
------------
Hello, friendly QA people!  Ron here.

Here's how to use this server.
I'll assume you're on a Macintosh.

Goal: 
	Setup:
		make sure "ruby" and "gem" are installed
		install "sinatra"
	Run:
		run the program "localLoggingServer.rb"
		run another program which watches for stuff to be logged

------------
Setup:
------------

1)  Open the Terminal.


2)  Make sure "ruby" and "gem" are installed.

Type these two commands:
	ruby --version
	gem --version
	
After each command, you should see a version number and other stuff, like:
	ruby 2.0.0p481
	gem 2.0.14
	
If, instead, you see messages like
	ruby: command not found
	gem: command not found
	
then let one of us programmers know, and we'll fix it.


3)  Install "sinatra"

Type this command:
	sudo gem install sinatra
	
It should ask you for your password.

It will then think for about 5 minutes, copying stuff from a server and printing status messages.  Wait until it says something like "Done," and seems to be waiting for more input from you.

If it gives you an error, let one of us know.


------------
Using this
------------

1) Open two Terminal windows.

2) In both window windows, change to this directory (where you're reading this file).  The easy way to do that:

	type the letters "cd" (don't hit Enter)
	hit the space bar
	drag this folder from the Finder into the Terminal window
	it should type the name of the folder, and all the folders above it
	hit "Enter"
	
	
(in progress.  just making a placeholder "readme" file.)