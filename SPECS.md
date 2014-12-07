ralbum - User Stories
=====================

Vision
======

ralbum is a (command line) tool to create a static HTML web album from
a folder containing images. It is completely file-based and does not
destroy the original images.

Story 1
=======

It should create the needed html files from a template. The template contains
all files needed to generate the web album.

Story 2
=======

It should generate different formats of the images, based on the album config.

Story 3
=======

It should store metadata for each image as plain json files beside the images. It should
also store metadata for the album as a plain json file.

Story 4
=======

It should work completely command-line driven, with different commands in the form:
"ralbum <command> <params ...>". The following main commands are understood:

* help: prints out all commands with a brief help
* create: Creates an album, means, creates all json files, overwrite existing, with a warning
* update: updates album and image infos, where necessary
* publish: creates the web album, copy all resources / images to a target destination,
    and creating the needed image thumbs / versions
* set: set album / image parameters
* get: get album / image parameters
* clear: clear out all files produced by ralbum

Story 5
=======

The "create" command writes all json files for each image, extracting the base information
and write a skeleton json. Each json is named as the image.json, e.g. for an image "pic1.png",
there should be a file "pic1.png.json". Also, the album itself is described as a json file,
as "album.json".

Story 6
=======

An album is a folder with images in it. For each album (folder), there is 1 album.json.
For each image, there is one image.json. 

Story 7
========
The command "publish" generates the web content, which goes in the album folder, too, and is
based on the template.

Story 8
=========

It should also be usable as Ruby module / library


Requirements
============

* bundler
* imagemagick (mac: port install imagemagick)


