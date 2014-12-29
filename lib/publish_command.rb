require 'highline/import'
require 'pathname'
require 'ralbum/album'
require 'ralbum/template'
require 'ralbum/publisher'

module Ralbum
    module Commands
        class Publish
            def initialize(args, options) 
                @album = Ralbum::Album.new(Dir.pwd)
                self.set_defaults(options)
                @options = options
                self.publish
            end

            def set_defaults(options)
                options.default \
                    :title => nil
            end

            def configure_template
                tpl = @options.template
                tpl = @album.template unless tpl
                tpl = "default" unless tpl
                tplObj = nil
                begin
                    tplObj = Ralbum::Template.new(tpl, File.join(File.dirname(Gem.bin_path('ralbum','ralbum.rb')),'..','templates'))
                    @album.template = tpl
                rescue
                    puts "Could not find template. Either give the name or path to a template via --template parameter, or put a 'template' config in album.json."
                    exit 2
                end
                return tplObj
            end

            def configure_destination
                dest = @options.to
                dest = @album.destination unless dest
                
                if not dest
                   puts "Please provide a destination path with --to <path>"
                   exit 2
                end

                @album.destination = dest

                if not (Pathname.new dest).absolute?
                    dest = File.join(@album.path,dest)
                end
                
                return dest
            end

            def publish
                template = self.configure_template
                dest = self.configure_destination                

                puts "please wait, work in progress..."
                publisher = Ralbum::Publisher.new(@album, template)
                publisher.force = @options.force
                publisher.add_listener(self)
                publisher.publish_to(dest)
                publisher.save_album if @options.save
            end

            def message(context, message)
                puts message
            end
        end
    end
end
