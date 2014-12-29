require 'rubygems'
require 'bundler/setup'

require 'json'

module Ralber

    ##
    # Represents a template
    class Template
        attr_reader :path,:config,:images_config


        def initialize(path, template_path = nil)
            @path = path
            @path = File.join(template_path,path) if not File.exists?(@path)
            raise StandardError, "File does not exits" if not File.exists?(@path)
            @path = File.expand_path(@path)
            raise StandardError, "template.json not found" if not File.exists?(self.json_path)
            @config = self.read_config
        end

        def json_path
            File.join(@path,'template.json')
        end

        def read_config
            begin
                conf = JSON.parse(File.read(self.json_path))
            rescue Exception=> e
                raise RuntimeError, "Could not parse template.json file: #{e.message}"
            end
        end

        def images_config
            raise RuntimeError,"template.json does not contain an 'images' config" unless @config.key?('images')
            @config['images']
        end

        def index_config
            if @config.has_key?('index')
                @config['index']
            else
                nil
            end
        end

        def detail_config
            if @config.has_key?('detail')
                @config['detail'] 
            else
                nil
            end
        end
    end
end