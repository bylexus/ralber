#!/bin/sh
bundle exec rspec -I "$(dirname $0)" --color --format doc tests/lib/
