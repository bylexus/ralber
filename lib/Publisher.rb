require 'rubygems'
require 'bundler/setup'

require 'json'
require_relative 'Album'
require_relative 'Template'
require 'fileutils'

##
# Represents a Publisher. The publisher takes a template and an album
# and processes / publishes the final content (html, images)
class Publisher
    attr_reader :album, :template

    def initialize(album,template)
        raise RuntimeError if not album.is_a?(Album)
        raise RuntimeError if not template.is_a?(Template)
        @album = album
        @template = template
        @listeners = []
    end

    def publish_to(path)
        self.ensure_path(path)
        self.copy_static_template_files_to(path)
        self.publish_images_to(path)
    end

    def publish_images_to(path)
        imgdir = @template.config['image_dir']
        self.inform_listeners(:publish_images_to,"Creating image versions: #{@template.images_config.keys.join(', ')} in #{path}/#{imgdir}")
        @template.images_config.each {|name,conf|
            destdir = File.join(path,imgdir,name)
            self.create_images(destdir,conf)
        }
    end

    def create_images(destdir,conf)
        @album.images.each {|img|
            self.ensure_path(destdir)
            self.inform_listeners(:create_resized_version,File.basename(img.path))
            img.create_resized_version((conf['format']).to_sym,conf['dimension'],destdir)
        }
    end

    def copy_static_template_files_to(path) 
        self.inform_listeners(:copy_static_template_files_to,"Copy static template files to #{path}")
        self.ensure_path(path)
        FileUtils.cp_r(File.join(@template.path,'.'),path)
    end


    def ensure_path(path)
        FileUtils.mkpath(path) unless File.exists?(path)
    end

    def add_listener(listener)
        @listeners << listener
    end

    def inform_listeners(msg_context,message)
        @listeners.each { |listener|
            listener.message(msg_context,message) if listener.respond_to?(:message)
        }
    end
end
