# Archruby

This gem aims to verify whether the system architecture is being respected by the developers. The application architecture is defined by the Software Architect through a YML file. After defining the architecture, you can use the tool to analyze if any part of the architecture is being broken in the system. To do this analysis it is necessary to pass the architecture definition file and the root path of the application to the archruby executable. The archruby executable will do an static scan in the application and generate an yaml file containing the violations. One picture of the entire application with all the communications will be generated either.

## Installation

Add this line to your application's Gemfile:

    gem 'archruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install archruby
