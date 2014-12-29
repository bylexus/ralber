module Ralber
    module Observable
    	def add_listener(listener)
    		@listeners = [] unless @listeners
    	    @listeners << listener
    	end

        def inform_listeners(msg_context,message)
        	if not @listeners.respond_to?(:each)
        		return;
        	end
            @listeners.each { |listener|
                listener.message(msg_context,message) if listener.respond_to?(:message)
            }
        end
    end
end