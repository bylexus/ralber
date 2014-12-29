require 'highline/import'
require 'pathname'
require 'ralbum/album'

module Ralbum
    module Commands
        class Update
            def initialize(args, options) 
                @album = Ralbum::Album.new(Dir.pwd)
                self.set_defaults(options)
                @options = options
                self.update
            end

            def set_defaults(options)
                options.default \
                    :title => nil
            end

            def update
                puts "please wait, work in progress..."
                @album.add_listener(self)
                @album.update
            end

            def message(context, message)
                puts message
            end
        end
    end
end
