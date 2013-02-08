# Meggy

Meggy is a mini tooset used to bring automation to your compute cloud (ec2).

### Requirements

Ruby 1.9.3+ 


#### Runtime Rubygem Dependencies

First you'll need [bundler](http://github.com/carlhuda/bundler) which can
be installed with a simple `gem install bundler`. Afterwords, do the following:

    bundle install

### Installing Meggy


Once your repository is set up, you can start working on the code. We do use
TDD with RSpec, so you'll need to get a development environment running.

### Commands


	pug	server create
	
	pug server status
	
	pug server start
	
	pug server stop
	
	pug sftp get
	
	pug sftp put
	
	pug login

	pug login 2 {2 => number of instances of the same server you wish to login}


# License

Meggy - A toolset to be used by megam systems for managing compute cloud.
This is used in conjuction with Chef (chef.megam.co)

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Kishorekumar (kishore<megam@megam.co.in>)
| **Copyright:**       | Copyright (c) 2012-2013 Megam Systems.
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
Wiki](http://wiki.opscode.com/display/Meggy/Home) is the definitive
source of user documentation.