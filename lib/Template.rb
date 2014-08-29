require 'rubygems'
require 'bundler/setup'

require 'json'
##
# Represents a template
class Template
    attr_reader :path,:config


    def initialize(path)
        raise StandardError, "File does not exits" if not File.exists?(path)
        @path = File.expand_path(path)
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
end
