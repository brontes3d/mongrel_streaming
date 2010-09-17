require 'rubygems'
require 'test/unit/notification'
require 'test/unit'
# require 'active_support'
#require 'action_pack/actioncontroller'

require 'action_controller'
require 'action_controller/integration'
require 'action_controller/test_case'
require 'action_controller/test_process'

require File.join(File.expand_path(File.dirname(__FILE__)), 'mock_mongrel_response')

unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.dirname(__FILE__)
end

require File.join(File.dirname(__FILE__), "..", "init")

MOCK_CONTROLLER_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'test_controllers')
require File.join(MOCK_CONTROLLER_DIR, 'application')

ActionController::Routing::Routes.clear!
ActionController::Routing.controller_paths= [ MOCK_CONTROLLER_DIR ]
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class MongrelStreamingTest < ActionController::TestCase

  def setup
    @controller = ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_setup
    get 'test'
    assert_equal("test", @response.body)
  end
  
  def test_render_mongrel_stream_proc
    thing_to_stream = "Hello World"
    
    get 'test_render_mongrel_stream_proc', :thing_to_stream => thing_to_stream
    
    response_body = MockMongrelResponse.new.get_body(@response.body)
    
    assert_equal(thing_to_stream, response_body)
  end

  def test_render_mongrel_stream_proc_with_translation_proc
    thing_to_stream = "Hello World"
    
    get 'test_render_mongrel_stream_with_custom_translation_proc', :thing_to_stream => thing_to_stream
    
    response_body = MockMongrelResponse.new.get_body(@response.body)
    
    assert_equal(thing_to_stream + " and " + thing_to_stream, response_body)
  end
  
end
