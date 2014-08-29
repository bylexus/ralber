require 'rubygems'
require 'bundler/setup'

require 'lib/Album'

a = Album.new(File.join('tests','fixtures','testalbum_publisher'))
a.create
