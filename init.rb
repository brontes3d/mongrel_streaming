$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'mongrel_streaming'
require 'mongrel'

ActionController::Base.class_eval do
  include MongrelStreaming
end