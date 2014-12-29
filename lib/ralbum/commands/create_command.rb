require 'highline/import'
require 'ralbum/album'

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
                puts("Creating album '#{@options.title}' in #{Dir.pwd}")
                album = Ralbum::Album.new(Dir.pwd)
                album.create({
                    'title' => @options.title,
                    'subtitle' => @options.subtitle,
                    'description' => @options.description
                }) do |img|
                    print "."
                end

                puts("\nDone. Found #{album.images.length} images. You can now edit album.json and/or publish the album.")
            end
        end

    end
end
