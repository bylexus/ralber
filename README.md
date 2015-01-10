[![Gem Version](https://badge.fury.io/rb/ralber.svg)](http://badge.fury.io/rb/ralber)

# ralber - a static web album generator written in ruby

> ralber is a (command line) tool to create a static HTML web album from a folder containing images. It is completely file-based and does not 
destroy the original images.

> Note that this library is in a VERY EARLY development stage and is not yet fully functional.

ralber is for people who:

* are not afraid of editing config files
* need a database-independent, VCS-aware static web album
* don't want to fiddle with thousands of settings but just want a simple web album

## Features

* Creates static Web Albums from a bunch of images
* Creates Index pages with configurable nr of images per index page
* Creates detail pages for each image
* HTML templates based on ERB-templates
* simple JSON configuration files for the album and the images
* Each template can define its own formats like thumbs, detail sizes etc
* Support for index-only albums for JavaScript-based image galeries
* Support for index pages, like this:
  ![alt text](doc/sample-index.jpg "Sample Index page")
* Support for detail pages, like this:
  ![alt text](doc/sample-detail.jpg "Sample Detail page")

You can watch a published demo at http://bylexus.github.io/ralber/demo/output/

## Upcoming Features

* extract EXIF data from the images
* support sorting by meta data (e.g. exif creation date)
* support for single images (e.g. title banner image on index page)
* renaming original files

## Requirements

* ruby >= 2.0
* The ImageMagick library
  * OS X using MacPorts: <code>sudo port install ImageMagick</code>
  * using Homebrew: <code>brew install imagemagick</code>
* (optional) ruby bundler - <code>gem install bundler</code>

## Installation

    gem install ralber
  
## Getting started

1. cd into your image directory
   `cd my-images/`

2. create the album
   `ralber.rb create --title "My holiday pictures"`

3. publish the album
   `ralber.rb publish --to /path/to/static/output/`

## In-detail: Usage

### Getting command overview

<code>ralber.rb help</code>

### Create album

<code>ralber.rb create [--title STRING] [--subtitle SRING] [--description STRING]</code>

The <code>create</code> command initializes the album in the current directory. This is the directory where your original images should be stored. A bunch of JSON file will be created in the <code>.ralber</code> folder, your original images won't be modified.

### Publish album

<code>ralber.rb publish [--to PATH] [--template NAME|PATH] [--force]</code>

Publishes the final web album:

* <code>--to</code> defines the output path. All files and images are copied to this folder. Existing files will be overwritten.
* <code>--template</code> defines the html template to use. If omitted, the <code>default</code> theme is used. The following bundled templates are available for now:
  - <code>default</code>: A index / detail page template
  - <code>fancybox-dark</code>: A single index page template with javascript gallery functionality
* <code>--force</code> re-recreates all images in the destination, even if they already exist. Otherwise, only generate new images.

### Update album

<code>ralber.rb update</code>

Updates an existing album: Finds new images and deletes orphaned config entries.

## Creating your own templates

TODO: (see examples bundled with the gem)

## List information

### List availabe bundled templates

<code>ralber.rb list templates</code>

list the available pre-bundled templates in the gem.
Use with <code>ralber.rb publish --template [name]</code>.

## album.json format

TODO 
Just a brain dump for now:
```
{
    "image_dir": "images",
    "images": {
        "thumb": {
            "dimension": "200x150",
            "format":"jpeg"
        },
        "detail": {
            "dimension": "1024x768",
            "format":"png"
        }
    },
    "index": {
        "pagesize":5,
        "filename_template": "index<%= page_nr if page_nr > 1 %>.html"
    }
}

```

## Use ralber as library in your own code

TODO

... TO BE CONTINUED ...
