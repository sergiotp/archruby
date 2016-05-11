if ENV['simplecov']
  require 'simplecov'
  SimpleCov.start do
    add_filter do |src|
      src.filename =~ /presenters/
    end
  end
end
require 'archruby'
