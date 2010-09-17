class ApplicationController < ActionController::Base
  
  def test
    render :text => "test"
  end
  
  def test_render_mongrel_stream_proc
    stringio_stream = StringIO.new(params[:thing_to_stream])
    
    stream_proc = Proc.new do |translate, output|
      translate.call(stringio_stream, output)
    end
    
    render_mongrel_stream_proc(stream_proc, :length => 200)
  end


  def test_render_mongrel_stream_with_custom_translation_proc
    stringio_stream = StringIO.new(params[:thing_to_stream])
    
    stream_proc = Proc.new do |translate, output|
      translate.call(stringio_stream, output)
    end
    
    translation_proc = Proc.new do |input, output|
      to_out = input.read
      output.write(to_out)
      output.write(" and ")
      output.write(to_out)
    end
    
    render_mongrel_stream_with_translation_proc(stream_proc, translation_proc, :length => 200)
  end

  
  def rescue_action(e) raise e end
    
end