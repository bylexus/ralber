require 'highline/import'
require 'pathname'
require 'ralber/template'

module Ralber
    module Commands
        class ListTemplates
            def initialize(args, options) 
                self.print_list
            end

            def print_list
                print "Availabe bundled templates:\n\n"
                Ralber::Template.bundled_templates.each {|entry|
                    print "Name: #{entry[:name]}\n"
                    print "Path: #{entry[:path]}\n\n"
                }
            end
        end
    end
end
