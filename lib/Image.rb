require 'json'

class Image
    attr :path

    def initialize(path)
        raise StandardError, "File does not exits" if not File.exists?(path)
        @path = File.expand_path(path)
        @title = File.basename(path)
    end

    def create
    end

    def json_path
        File.expand_path(@path)+'.json'
    end

    def image_info
        info = {
            "path" => @path,
            "title" => @title
        }
    end
end
