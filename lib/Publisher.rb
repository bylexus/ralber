require 'rubygems'
require 'bundler/setup'

require 'json'
require 'erb'
require_relative 'Album'
require_relative 'Template'
require 'fileutils'

##
# Represents a Publisher. The publisher takes a template and an album
# and processes / publishes the final content (html, images)
class Publisher
    attr_reader :album, :template
    attr_writer :skip_image_creation

    def initialize(album,template)
        raise RuntimeError if not album.is_a?(Album)
        raise RuntimeError if not template.is_a?(Template)
        @album = album
        @template = template
        @listeners = []
        @skip_image_creation = false
    end

    def publish_to(path)
        self.inform_listeners(:using_template,"Using template in #{@template.path}")
        
        self.ensure_path(path)
        self.copy_static_template_files_to(path)
        self.publish_images_to(path) unless @skip_image_creation == true
        self.publish_index_to(path)
        self.publish_detail_pages_to(path)
    end

    def publish_images_to(path)
        imgdir = @template.config['image_dir']
        self.inform_listeners(:publish_images_to,"Creating image versions: #{@template.images_config.keys.join(', ')} in #{path}/#{imgdir}")
        @template.images_config.each {|name,conf|
            destdir = File.join(path,imgdir,name)
            self.create_images(destdir,conf,name )
        }
    end

    def publish_index_to(path)
        self.inform_listeners(:publish_index_to,"Page size: #{page_size}, #{pages} pages with #{@album.images.length} images.")
        page_tpl = ERB.new(File.read(File.join(@template.path,'index.html.erb')))
        album = @album
        (1..pages).each {|page_nr|
            images = @album.images[((page_nr-1)*page_size)...((page_nr-1)*page_size+page_size)]
            name = index_page(page_nr)
            outpath = File.join(path,name)
            page_content = page_tpl.result(binding)
            File.write(outpath,page_content)
            self.inform_listeners(:publish_index_to,"Index page written: #{outpath}")
        
        }
    end

    def publish_detail_pages_to(path)
        page_tpl = ERB.new(File.read(File.join(@template.path,'detail.html.erb')))
        @album.images.each_with_index {|image, index|
            page_nr = index/page_size+1
            images = @album.images
            name = detail_page(index)
            outpath = File.join(path,name)
            page_content = page_tpl.result(binding)
            File.write(outpath,page_content)
            self.inform_listeners(:publish_detail_to,"Detail page written: #{outpath}")
        }
    end

    def page_size
        @template.config['index']['pagesize'] || 20
    end

    def pages
        (@album.images.length / page_size().to_f).ceil
    end

    def index_page(page_nr)
        name_tpl = ERB.new(@template.config['index']['filename_template'])
        return name_tpl.result(binding)
    end

    def detail_page(index)
        name_tpl = ERB.new(@template.config['detail']['filename_template'])
        return name_tpl.result(binding) 
    end

    def image_info(image, version = nil)
        version_info = @template.config['images'][version] if version
        filename = image.get_resized_name(File.basename(image.path), version_info['format'].to_sym)
        imagebase = @template.config['image_dir']
        info = {
            'filename' => filename,
            'rel_path' => (version_info ? File.join(imagebase,version,filename) : nil)
        }
        return info
    end

    def create_images(destdir,conf,name = '')
        @album.images.each {|img|
            info = self.image_info(img,name)
            self.ensure_path(destdir)
            self.inform_listeners(:create_resized_version,"Working on: #{name}: #{info['rel_path']}")
            img.create_resized_version((conf['format']).to_sym,conf['dimension'],destdir)
        }
    end

    def copy_static_template_files_to(path) 
        self.inform_listeners(:copy_static_template_files_to,"Copy static template files to #{path}")
        self.ensure_path(path)
        FileUtils.cp_r(File.join(@template.path,'.'),path)
        self.clean_dest_path(path)
    end

    ##
    # Cleans unwanted template files from the destination path
    def clean_dest_path(path)
        [
            File.join(path,'template.json'),
            File.join(path,'index.html.erb')
        ].each do |f|
            File.delete(f) if File.exists?(f)
        end
        
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
