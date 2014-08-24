require 'rubygems'
require 'bundler/setup'

require 'lib/Image'
require 'json'
require 'fastimage'

RSpec.describe Image do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))

    end

    after(:example) do
        # Dir.glob(File.join(@fixpath,'*.json')).each { |f| File.delete(f) }
        json1 = File.join(@fixpath,'image1.jpg.json')
        File.delete(json1) if File.exists?(json1)
    end


    it "raises an error if the given path is no file" do
        expect{Image.new('/some/path/to/nowhere')}.to raise_error
    end
        
    it "initializes with the given path" do
        image = Image.new(File.join(@fixpath,'image1.jpg'))
        expect(image.path).to eq(File.join(@fixpath,'image1.jpg'))
    end

    it "should extract the image info on instantiation for a new image" do
        image = Image.new(File.join(@fixpath,'image1.jpg'))
        expect(image.title).to eq('image1.jpg')
        expect(image.type).to eq(:jpeg)
        expect(image.description).to eq('')
        expect(image.width).to eq(2048)
        expect(image.height).to eq(1536)
    end

    it "should extract the image info on instantiation for a configured image" do
        image = Image.new(File.join(@fixpath,'image2.jpg'))
        expect(image.title).to eq('My Little Pony')
        expect(image.type).to eq(:jpeg)
        expect(image.description).to eq('a small pony')
        expect(image.width).to eq(2048)
        expect(image.height).to eq(1536)
    end

    it "should raise an error if the image file cannot be inspected / parsed" do
        expect { Image.new(File.join(@fixpath,'chrüsimüsi.jpg')) }.to raise_error
    end

    describe "#get_image_info" do
        it "should return the base image information for an existing image" do
           image = Image.new(File.join(@fixpath,'image1.jpg'))
           allow(image).to receive(:image_type) { :jpeg }
           allow(image).to receive(:image_dimensions) { {:width => 2048,:height=>1536} }
           info = image.get_image_info()
           expect(info).to include("title"=>'image1.jpg')
           expect(info).to include("description"=>'')
           expect(info).to include("type" => :jpeg)
           expect(info).to include("width" => 2048)
           expect(info).to include("height" => 1536)
        end
    end

    describe "#json_path" do
        it "should return the full path to the image's json description file" do
           image = Image.new(File.join(@fixpath,'image1.jpg'))
           path = image.json_path
           expect(path).to eq(File.expand_path(File.join(@fixpath,'image1.jpg.json')))
        end
    end

    describe "#create" do
        it "should create a image.ext.json file in the same location as the image" do
           image = Image.new(File.join(@fixpath,'image1.jpg'))
           image.create
           expect(File.exists?(image.json_path)).to be_truthy
        end

        it "should have written the base image information to the file" do
           image = Image.new(File.join(@fixpath,'image1.jpg'))
           image.create
           obj = JSON.parse(File.read(image.json_path))
           expect(obj).to include('title'=>'image1.jpg')
        end
    end

    describe "#image_type" do
        it "should return the correct mime type for a given image" do
           image = Image.new(File.join(@fixpath,'image1.jpg'))
           expect(image.image_type).to eq(:jpeg)
        end
    end

    describe "#image_dimensions" do
        it "should return the image dimensions as :width/:height hash" do
           image = Image.new(File.join(@fixpath,'image1.jpg'))
           expect(image.image_dimensions).to include(:width=>2048,:height=>1536)
        end
    end

    describe "#create_resized_image" do
        it "should create a smaller version by giving the width only" do
            image = Image.new(File.join(@fixpath,'image1.jpg'))
            img1 = File.join(@fixpath,'image1_width.png')
            image.create_resized_image(img1,200)
            expect(File.exists?(img1)).to be_truthy
            dim = FastImage.size(img1)
            expect(dim[0]).to eq(200)
            expect(dim[1]).to eq(200*image.height/image.width)

            dim = FastImage.type(img1)
            expect(dim).to equal(:png)
            # File.delete(img1)
        end

    end
end
