require 'rubygems'
require 'bundler/setup'

require 'lib/Publisher'
require 'lib/Album'
require 'lib/Template'
require 'json'

RSpec.describe Publisher do
    before(:example) do
        @albumpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures','testalbum_publisher'))
        @templatepath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures','template3'))
        @album = Album.new(@albumpath)
        @album.create
        @template = Template.new(@templatepath)
    end

    after(:example) do
    end

    describe "#initialize" do
        it "should intialize if a correct album and template is given" do
            p = Publisher.new(@album,@template)
            expect(p).to be
        end

        it "should raise an error if either album or template is not correct" do
            expect {
                Publisher.new("test",@template)
            }.to raise_error
            expect {
                Publisher.new(@album,2)
            }.to raise_error
        end
    end


end
