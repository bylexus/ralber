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
    end

    def publish_to(path)
        self.ensure_path(path)
        imgdir = @template.config['image_dir']
        @template.images_config.each {|name,conf|
            destdir = File.join(path,imgdir,name)
            self.create_images(destdir,conf)
        }
    end

    def create_images(destdir,conf)
        @album.images.each {|img|
            self.ensure_path(destdir)
            img.create_resized_version((conf['format']).to_sym,conf['dimension'],destdir)
        }
    end

    def ensure_path(path)
        FileUtils.mkpath(path) unless File.exists?(path)
    end
end
