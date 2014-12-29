require 'rubygems'
require 'bundler/setup'

require 'ralber/publisher'
require 'ralber/album'
require 'ralber/template'
require 'json'
require 'tmpdir'

RSpec.describe Ralber::Publisher do
    before(:example) do
        @fixtures = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))
        @albumpath = File.expand_path(File.join(@fixtures,'testalbum_publisher'))
        @templatepath = File.expand_path(File.join(@fixtures,'template1'))
        @album = Ralber::Album.new(@albumpath)
        @album.create
        @template = Ralber::Template.new(@templatepath)
    end

    after(:example) do
    end

    describe "#initialize" do
        it "should intialize if a correct album and template is given" do
            p = Ralber::Publisher.new(@album,@template)
            expect(p).to be
            expect(p.album).to equal(@album)
            expect(p.template).to equal(@template)
        end

        it "should raise an error if either album or template is not correct" do
            expect {
                Ralber::Publisher.new("test",@template)
            }.to raise_error
            expect {
                Ralber::Publisher.new(@album,2)
            }.to raise_error
        end
    end

    describe "#ensure_path" do
        it "should create the destination path if it does not already exists" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Ralber::Publisher.new(@album,@template)
                p.ensure_path(dest)
                expect(File.directory?(dest)).to be_truthy
            }
        end

    end

    describe "#publish_to" do
        it "should call ensure_pathand publish_images_to" do
            p = Ralber::Publisher.new(@album,@template)
            expect(p).to receive(:ensure_path).with('/some/path')
            expect(p).to receive(:publish_images_to).with('/some/path')
            expect(p).to receive(:copy_static_template_files_to).with('/some/path')
            p.publish_to('/some/path')
        end
    end

    describe "#publish_images_to" do
        it "should create the image versions in the destination folder" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Ralber::Publisher.new(@album,@template)
                p.publish_to(dest)
                expect(File.exists?(File.join(dest,'images','thumb','img1.jpg'))).to be_truthy
                expect(File.exists?(File.join(dest,'images','detail','img1.png'))).to be_truthy
            }
        end
    end

    describe "#copy_static_template_files_to" do
        it "should copy all the static template files to the destination dir in the correct tree path" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Ralber::Publisher.new(@album,@template)
                p.copy_static_template_files_to(dest)
                expect(File.exists?(File.join(dest,'dir1','testfile2.txt'))).to be_truthy
                expect(File.exists?(File.join(dest,'dir1','dir2','testfile1.txt'))).to be_truthy
            }
        end
        
    end

    describe "#create_images" do
        it "should create all images of an album for one image configuration" do
            Dir.mktmpdir { |dir|
                dest = File.join(dir,'sub','dir')
                p = Ralber::Publisher.new(@album,@template)
                p.create_images(dest,@template.images_config['thumb'],'thumb')
                expect(File.exists?(File.join(dest,'img1.jpg'))).to be_truthy
            }
        end
    end
end
