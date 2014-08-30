require 'rubygems'
require 'bundler/setup'

require 'lib/Publisher'
require 'lib/Album'
require 'lib/Template'
require 'json'
require 'tmpdir'

RSpec.describe Publisher do
    before(:example) do
        @fixtures = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))
        @albumpath = File.expand_path(File.join(@fixtures,'testalbum_publisher'))
        @templatepath = File.expand_path(File.join(@fixtures,'template1'))
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
            expect(p.album).to equal(@album)
            expect(p.template).to equal(@template)
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

    describe "#publish_to" do
        it "should create the destination path if it does not already exists" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Publisher.new(@album,@template)
                p.publish_to(dest)
                expect(File.directory?(dest)).to be_truthy
            }
        end

        it "should create the image versions in the destination folder" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Publisher.new(@album,@template)
                p.publish_to(dest)
                expect(File.exists?(File.join(dest,'images','thumb','img1.jpg'))).to be_truthy
                expect(File.exists?(File.join(dest,'images','detail','img1.png'))).to be_truthy
            }
        end
    end
    
    describe "#create_images" do
        it "should create all images of an album for one image configuration" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Publisher.new(@album,@template)
                p.create_images(dest,@template.images_config['thumb'])
                expect(File.exists?(File.join(dest,'img1.jpg'))).to be_truthy
            }
        end
    end
end
