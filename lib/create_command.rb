require 'highline/import'
require 'lib/Album'

module Ralbum
    module Commands
        class Create
            def initialize(args, options) 
                self.set_defaults(options)
                @options = options
                self.ask_title if options.title == nil
                self.create_album
            end

            def set_defaults(options)
                options.default \
                    :title => nil
            end

            def ask_title
                @options.title = ask("Album title? ", String)
            end

            def create_album
                puts("Creating album in #{Dir.pwd}")
                album = Album.new(Dir.pwd)
                album.create({
                    'title' => @options.title,
                    'subtitle' => @options.subtitle,
                    'description' => @options.description
                })
            end
        end

    end
end
