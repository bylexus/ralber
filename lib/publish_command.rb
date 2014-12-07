require 'highline/import'
require_relative 'Album'
require_relative 'Template'
require_relative 'Publisher'

module Ralbum
    module Commands
        class Publish
            def initialize(args, options) 
                @album = Album.new(Dir.pwd)
                self.set_defaults(options)
                @options = options
                @template = self.find_template
                self.publish
            end

            def set_defaults(options)
                options.default \
                    :title => nil
            end

            def find_template
                tpl = @album.template
                tpl = @options.template unless tpl
                tplObj = nil
                begin
                    tplObj = Template.new(tpl)
                    @album.template = tpl
                rescue
                    puts "Could not find template. Either give the name or path to a template via --template parameter, or put a 'template' config in album.json."
                    exit 2
                end
                return tplObj
            end

            def publish
                dest = @options.to
                if not dest
                   puts "Please provide a destination path with --to <path>"
                   exit 2
                end

                puts "please wait, work in progress..."
                publisher = Publisher.new(@album, @template)
                print @options.inspect
                publisher.skip_image_creation = @options.skip_image_creation
                publisher.add_listener(self)
                publisher.publish_to(dest)
            end

            def message(context, message)
                if context == :create_resized_version
                    puts "    Working on #{message}"
                else
                    puts message
                end
            end
        end
    end
end
