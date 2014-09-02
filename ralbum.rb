#!/usr/bin/env ruby

# -*- encoding: utf-8 -*-
$:.push File.expand_path("..", __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'commander/import'
require_relative 'lib/create_command'
require_relative 'lib/publish_command'

program :version, '0.0.1'
program :description, 'A static web album generator'
 
command :create do |c|
  c.syntax = 'ralbum create [options]'
  c.summary = 'Initializes the current folder as an Album.'
  c.description = 'creates an initial album.json and grabs image information for all images found in the directory.'
  c.example 'Simple create', 'ralbum create'
  c.option '--title STRING', String, 'Sets the album title. Defaults to the current folder name'
  c.option '--subtitle STRING', String, 'Sets the album subtitle.'
  c.option '--description STRING', String, 'Sets the album description.'
  c.when_called Ralbum::Commands::Create
end

command :publish do |c|
  c.syntax = 'ralbum publish [options]'
  c.summary = 'Publishes an existing album: Copies the images and web content, and generate the dynamic files.'
  c.description = ''
  c.option '--template STRING', String, 'Name or path to a Template'
  c.option '--to STRING',String, 'Destination path to which the web album is published'
  c.option '--save',String, 'If set, the album.json is updated with the delivered command line options, like publish path'
  c.example 'Simple publish', 'ralbum publish --to /path/to/final/destination'
  c.when_called Ralbum::Commands::Publish
end

command :update do |c|
  c.syntax = 'ralbum update [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Ralbum::Commands::Update
  end
end

