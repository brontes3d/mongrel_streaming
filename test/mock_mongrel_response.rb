# BEGIN RANT
# ActionController::IntegrationTest is designed to help you test your controllers
# if you do render :text => Proc.new { |response, output|
# @response.body is going to be that proc
# AND YET: that proc WILL have already been called... and the output it writes calculated
# AND: that's the 'body' in 
#     status, headers, body = app.call(env) 
# from actionpack-2.3.4/lib/action_controller/integration.rb:313
# and yet RAILS IS TOO CLEVER
# and instead of making THAT body available to your test
# it gives you only the proc
# 
# You COULD get that body, but only if you never invoke ActionController
# this is supposed to be so that you can test Rails Metal and Rack Middleware
# it's the else after "if @controller = ActionController::Base.last_instantiation" integration.rb:339
#
# It seems they've made the opinionated decision, that you would never want to test:
#   combination of ActionController and Rack in a single integration test
# And that would never want to test: 
#   WHAT'S ACTUALLY SENT, in the response when you are integration testing with ActionController
#   Isn't that the point of integration test thou?
#   can't functional testing serve us well enough to test the controller without the rack parts?
#   
# I do not agree with these opinionated decisions
#
# END RANT
class MockMongrelResponse

  def initialize
    @written = StringIO.new  
  end

  def write(to_write)
    @written.write(to_write)
  end
  
  def get_body(response_proc)
    response_proc.call(self, self)
    @written.seek(0)
    @written.read
  end

end
