ralbum - User Stories
=====================

Vision
======

ralbum is a command line tool to create a static HTML web album from
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

It should be completely command-line driven, with different commands in the form:
"ralbum <command> <params ...>"

Story 5
=======

The "init" command writes all json files for each image, extracting the base information
and write a skeleton json. Each json is named as the image.json, e.g. for an image "pic1.png",
there should be a file "pic1.png.json". Also, the album itself is described as a json file,
as "album.json".

Story 6
=======

An album is a folder with images in it. For each album (folder), there is 1 album.json.
For each image, there is one image.json. 

Story 7
========
The command "generate" generates the web content, which goes in the album folder, too, and is
based on the template.
