require 'rubygems'
require 'bundler/setup'

require 'json'
require 'lib/Album'
require 'lib/Template'

##
# Represents a Publisher. The publisher takes a template and an album
# and processes / publishes the final content (html, images)
class Publisher
    def initialize(album,template)
        raise RuntimeError if not album.is_a?(Album)
        raise RuntimeError if not template.is_a?(Template)
    end
end
