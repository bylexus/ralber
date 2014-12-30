#!/usr/bin/env ruby

# -*- encoding: utf-8 -*-
$:.push File.expand_path("..", __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'commander/import'
require 'ralber/commands/create_command'
require 'ralber/commands/publish_command'
require 'ralber/commands/update_command'

program :version, '0.0.2'
program :description, 'A static web album generator'
 
command :create do |c|
  c.syntax = 'ralber create [options]'
  c.summary = 'Initializes the current folder as an Album.'
  c.description = 'creates an initial album.json and grabs image information for all images found in the directory.'
  c.example 'Simple create', 'ralber create'
  c.option '--title STRING', String, 'Sets the album title. Defaults to the current folder name'
  c.option '--subtitle STRING', String, 'Sets the album subtitle.'
  c.option '--description STRING', String, 'Sets the album description.'
  c.when_called Ralber::Commands::Create
end

command :publish do |c|
  c.syntax = 'ralber publish [options]'
  c.summary = 'Publishes an existing album: Copies the images and web content, and generates the dynamic files.'
  c.description = ''
  c.option '--template STRING', String, 'Name or path to a Template'
  c.option '--to STRING',String, 'Destination path to which the web album is published'
  c.option '--save',String, 'If set, the album.json is updated with the delivered command line options, like publish path'
  c.option '--force', 'If set, all images are (re-)created, even if they already exist in the destination. Default is to not override any images.'
  c.example 'Simple publish', 'ralber publish --to /path/to/final/destination'
  c.when_called Ralber::Commands::Publish
end

command :update do |c|
  c.syntax = 'ralber update [options]'
  c.summary = 'Updates the actual album.'
  c.description = 'Updates the album.json file with new / removed images, and updates image information.'
  c.example 'Simple update', 'ralber update'
  c.when_called Ralber::Commands::Update
end

