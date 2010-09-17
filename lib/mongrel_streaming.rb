module MongrelStreaming
  
  mattr_accessor :rescue_proc
  
  def self.default_translation_proc
    Proc.new do |input, out|
      total_written = 0
      while chunk = input.read(16384)
        begin
          out.write(chunk)
        rescue Errno::EPIPE => e
          raise e, "(re-raised) #{e.message} -- total_written: #{total_written} -- pending chunk: #{chunk.size}"
        rescue IOError => e
          raise e, "(re-raised) #{e.message} -- total_written: #{total_written} -- pending chunk: #{chunk.size}"
        end
        total_written += chunk.size
      end
    end
  end
  
  def render_mongrel_stream_proc(stream_proc, headers = {})
    render_mongrel_stream_with_translation_proc(stream_proc, MongrelStreaming.default_translation_proc, headers)
  end

  def render_mongrel_stream_with_translation_proc(stream_proc, translation_proc, headers = {})
    send_file_headers! headers
    @performed_render = false
    
    render :status => 200, :text => (Proc.new do |action_controller_response, output|
      begin
        stream_proc.call(translation_proc, output)
      rescue => e
        if MongrelStreaming.rescue_proc
          MongrelStreaming.rescue_proc.call(e, self)
        else
          raise e
        end
      ensure
        if Thread.current[:cleanup_proc]
          Thread.current[:cleanup_proc].call
          Thread.current[:cleanup_proc] = nil
        end
      end
    end)
  end
  
end