require 'rubygems'
require 'bundler/setup'

require 'ralbum/image'
require 'json'
require 'rmagick'
require 'tmpdir'

RSpec.describe Ralbum::Image do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))

    end

    after(:example) do
        # Dir.glob(File.join(@fixpath,'*.json')).each { |f| File.delete(f) }
        json1 = File.join(@fixpath,'.ralbum','image1.jpg.json')
        File.delete(json1) if File.exists?(json1)
    end


    it "raises an error if the given path is no file" do
        expect{Ralbum::Image.new('/some/path/to/nowhere')}.to raise_error
    end
        
    it "initializes with the given path" do
        image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
        expect(image.path).to eq(File.join(@fixpath,'image1.jpg'))
    end

    it "should set new (empty) image info on instantiation for a new image" do
        image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
        expect(image.title).to eq('image1.jpg')
        expect(image.type).to eq(nil)
        expect(image.description).to eq('')
        expect(image.width).to eq(0)
        expect(image.height).to eq(0)
    end

    it "should extract the image info on instantiation for a configured image" do
        image = Ralbum::Image.new(File.join(@fixpath,'image2.jpg'))
        expect(image.title).to eq('My Little Pony')
        expect(image.type).to eq(:jpeg)
        expect(image.description).to eq('a small pony')
        expect(image.width).to eq(124)
        expect(image.height).to eq(234)
    end


    describe "#get_image_info" do
        it "should return the base image information for a new image" do
            image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
            expect(image.title).to eq('image1.jpg')
            expect(image.type).to eq(nil)
            expect(image.description).to eq('')
            expect(image.width).to eq(0)
            expect(image.height).to eq(0)
        end

        it "should return the base image information for an existing image" do
            image = Ralbum::Image.new(File.join(@fixpath,'image2.jpg'))
            expect(image.title).to eq('My Little Pony')
            expect(image.type).to eq(:jpeg)
            expect(image.description).to eq('a small pony')
            expect(image.width).to eq(124)
            expect(image.height).to eq(234)
        end
    end

    describe "#json_path" do
        it "should return the full path to the image's json description file" do
           image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
           path = image.json_path
           expect(path).to eq(File.expand_path(File.join(@fixpath,'.ralbum','image1.jpg.json')))
        end
    end

    describe "#create" do
        it "should raise an error if the image file cannot be inspected / parsed" do
            expect { Ralbum::Image.new(File.join(@fixpath,'chrüsimüsi.jpg')).create }.to raise_error
        end

        it "should create a image.ext.json file in the same location as the image" do
           image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
           image.create
           expect(File.exists?(image.json_path)).to be_truthy
        end

        it "should have written the base image information to the file" do
           image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
           image.create
           obj = JSON.parse(File.read(image.json_path))
           expect(obj).to include('title'=>'image1.jpg')
           expect(obj).to include('width'=>2048)
           expect(obj).to include('height'=>1536)
           expect(obj).to include('type'=>"jpeg")
        end
    end

    describe "#image_metadata" do
        it "should return the image file's metadata like size and type" do
           image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
           meta = image.image_metadata
           expect(meta).to include(:width => 2048,:height => 1536, :type => :jpeg)
        end
    end

    describe "#create_resized_image" do
        it "should create a smaller version by giving the width only" do
            image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
            image.create
            img1 = File.join(@fixpath,'image1_width.png')
            image.create_resized_image(img1,"200")
            expect(File.exists?(img1)).to be_truthy
            dim = Magick::Image::read(img1).first
            expect(dim.columns).to eq(200)
            expect(dim.rows).to eq(200*image.height/image.width)
            File.delete(img1)
        end

        it "should create a smaller version by giving the height only" do
            image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
            image.create
            img1 = File.join(@fixpath,'image1_height.png')
            image.create_resized_image(img1,"x200")
            expect(File.exists?(img1)).to be_truthy
            dim = Magick::Image::read(img1).first
            expect(dim.rows).to eq(200)
            expect(dim.columns).to eq((200.0*image.width/image.height).round)
            File.delete(img1)
        end
    end

    describe "#create_resized_version" do
        it "should create a resized version of the given type and in the given output dir" do
            image = Ralbum::Image.new(File.join(@fixpath,'image1.jpg'))
            image.create
            Dir.mktmpdir {|dir|
                image.create_resized_version(:png,"200",dir)
                expect(File.exists?(File.join(dir,'image1.png'))).to be_truthy
                dim = Magick::Image::read(File.join(dir,'image1.png')).first
                expect(dim.columns).to eq(200)
                expect(dim.rows).to eq(150)
            }
        end
    end
end
