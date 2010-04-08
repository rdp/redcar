
{Redcar}
========

by Daniel Lucraft
http://RedcarEditor.com/

## DESCRIPTION

A pure Ruby text editor running on JRuby. 

## INSTALLATION

You must have Java installed. 

    $ sudo gem install redcar
    $ sudo redcar install
    
NB the install will take a minute or so to complete as it has to download about
15MB of jar files.

## USAGE

Run 

    $ redcar --help
    
for a list of options.

## INSTALLING FROM SOURCE

If you want to contribute to Redcar, you can install it from the source code.
Download from github, checkout the submodules and build JavaMateView. You will need Ant 
installed, and RSpec and Cucumber installed as JRuby gems.

    $ git clone git://github.com/danlucraft/redcar.git
    $ cd redcar
    $ git submodule init
    $ git submodule update
    $ jruby bin/redcar install
    $ jruby -S rake build

To run on Linux and Windows:

    $ jruby bin/redcar

To run on OSX:

    $ jruby -J-XstartOnFirstThread bin/redcar        

You may also need to install the rake, rspec and cucumber gems.

## PROBLEMS?

* Irc at #redcar on irc.freenode.net
* Mailing list at http://groups.google.com/group/redcar-editor

## TESTS

To run all specs and features:

    $ jruby -S rake

NB. Features work with Cucumber version 0.4.2, you may have problems with other versions because for the moment we are patching Cucumber dynamically to support dependencies between sets of features.

## TESTS (specs)

On OSX:

    $ jruby -J-XstartOnFirstThread -S spec plugins/#{plugin_name}/spec/

On Linux:

    $ jruby -S spec plugins/#{plugin_name}/spec/

Or $ jruby -S rake specs

For all of them.
  
## TESTS (features)

On OSX:

    $ jruby -J-XstartOnFirstThread -J-Djruby.launch.inproc=false bin/cucumber plugins/#{plugin_name}/features

On Linux/Windows:

    $ jruby -J-Djruby.launch.inproc=false bin/cucumber plugins/#{plugin_name}/features # or specify single feature filename

Or $ jruby -S rake cucumber

For all of them.

## LICENSE

Redcar is copyright 2007-2010 Daniel Lucraft and contributors. 
It is licensed under the GPL2. See the included LICENSE file for details.

