require 'rubygems'
require 'bundler/setup'
require 'digest'
require 'ralber/image'
require 'json'
require 'rmagick'
require 'tmpdir'
require 'time'

RSpec.describe Ralber::Image do

    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))
        @image1_path = File.join(@fixpath,'image1.jpg')
        @image1_md5 = Digest::MD5.file(@image1_path).hexdigest

        @image2_path = File.join(@fixpath,'image2.jpg')
        @image2_md5 = Digest::MD5.file(@image2_path).hexdigest

        @exif_image_path = File.join(@fixpath,'exif_img.jpg')
    end

    after(:example) do
        # Dir.glob(File.join(@fixpath,'*.json')).each { |f| File.delete(f) }
        json1 = File.join(@fixpath,'.ralber','image1.jpg.json')
        File.delete(json1) if File.exists?(json1)
    end


    it "raises an error if the given path is no file" do
        expect{Ralber::Image.new('/some/path/to/nowhere')}.to raise_error
    end
        
    it "initializes with the given path" do
        image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
        expect(image.path).to eq(File.join(@fixpath,'image1.jpg'))
    end

    it "should set new (empty) image info on instantiation for a new image" do
        image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
        expect(image.title).to eq('image1.jpg')
        expect(image.type).to eq(:jpeg)
        expect(image.description).to eq('')
        expect(image.width).to eq(2048)
        expect(image.height).to eq(1536)
        expect(image.published_md5).to eq('')
    end

    it "should extract the image info on instantiation for a configured image" do
        image = Ralber::Image.new(File.join(@fixpath,'image2.jpg'))
        expect(image.title).to eq('My Little Pony')
        expect(image.type).to eq(:jpeg)
        expect(image.description).to eq('a small pony')
        expect(image.width).to eq(124)
        expect(image.height).to eq(234)
        expect(image.published_md5).to eq(@image2_md5)
    end


    describe "#get_image_info" do
        it "should return the base image information for a new image" do
            image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
            expect(image.title).to eq('image1.jpg')
            expect(image.type).to eq(:jpeg)
            expect(image.description).to eq('')
            expect(image.width).to eq(2048)
            expect(image.height).to eq(1536)
            expect(image.published_md5).to eq('')
        end

        it "should return the base image information for an existing image" do
            image = Ralber::Image.new(File.join(@fixpath,'image2.jpg'))
            expect(image.title).to eq('My Little Pony')
            expect(image.type).to eq(:jpeg)
            expect(image.description).to eq('a small pony')
            expect(image.width).to eq(124)
            expect(image.height).to eq(234)
            expect(image.published_md5).to eq(@image2_md5)
        end
    end

    describe "#json_path" do
        it "should return the full path to the image's json description file" do
           image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
           path = image.json_path
           expect(path).to eq(File.expand_path(File.join(@fixpath,'.ralber','image1.jpg.json')))
        end
    end

    describe "#create" do
        it "should raise an error if the image file cannot be inspected / parsed" do
            expect { Ralber::Image.new(File.join(@fixpath,'chrüsimüsi.jpg')).create }.to raise_error
        end

        it "should create a image.ext.json file in the same location as the image" do
           image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
           image.create
           expect(File.exists?(image.json_path)).to be_truthy
        end

        it "should have written the base image information to the file" do
           image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
           image.create
           obj = JSON.parse(File.read(image.json_path))
           expect(obj).to include('title'=>'image1.jpg')
           expect(obj).to include('width'=>2048)
           expect(obj).to include('height'=>1536)
           expect(obj).to include('type'=>"jpeg")
           expect(obj).to include('published_md5'=>'')
        end
    end

    describe "#image_metadata" do
        it "should return the image file's metadata like size and type" do
           image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
           meta = image.image_metadata
           expect(meta).to include(
            :width => 2048,
            :height => 1536,
            :type => 
            :jpeg,
            :published_md5 => ''
            )
        end
    end

    describe "#create_resized_image" do
        it "should create a smaller version by giving the width only" do
            image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
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
            image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
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
            image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
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

    describe "#calc_md5" do
        it "should return the real file's md5" do
            image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
            md5 = image.calc_md5
            expect(md5).to eq('bf05d4304fa5d13d9d273462e45fa4b6')
        end

        it "should call Digest::MD5.file only once, even if called 2 times" do
            expect(Digest::MD5).to receive(:file).once.and_call_original
            image = Ralber::Image.new(File.join(@fixpath,'image1.jpg'))
            image.calc_md5
            image.calc_md5
        end
    end

    describe "has_changed" do
        it "should return true if the config's md5 differs from the file's md5" do
            image = Ralber::Image.new(File.join(@fixpath,'image3.jpg'))
            expect(image.has_changed()).to be_truthy
        end

        it "should return false if the config's md5 equals the file's md5" do
            image = Ralber::Image.new(File.join(@fixpath,'image2.jpg'))
            expect(image.has_changed()).to be_falsy
        end
    end

    describe "exif_data" do
        it "should respond to exif_data" do
            image = Ralber::Image.new(@exif_image_path)
            expect(image).to respond_to :exif_data
        end

        it "should return a hash with the expected keys" do
            image = Ralber::Image.new(@exif_image_path)
            ret = image.exif_data
            expect(ret).to respond_to :key
            expect(ret.key?(:exif)).to be_truthy
            expect(ret.key?(:width)).to be_truthy
            expect(ret.key?(:height)).to be_truthy
            expect(ret.key?(:date_time)).to be_truthy
            expect(ret.key?(:date_time_original)).to be_truthy
            expect(ret.key?(:gps_longitude)).to be_truthy
            expect(ret.key?(:gps_latitude)).to be_truthy
            expect(ret.key?(:gps_altitude)).to be_truthy
            expect(ret.key?(:exposure_time)).to be_truthy
            expect(ret.key?(:focal_length)).to be_truthy
            expect(ret.key?(:f_number)).to be_truthy
        end

        it "should return the correct data from a jpeg image" do
            image = Ralber::Image.new(@exif_image_path)
            ret = image.exif_data
            expect(image.type).to equal(:jpeg)
            expect(ret).to include(
                :exif => true,
                :width => 200,
                :height => 133,
                :date_time => Time.parse('2014-07-13 10:31:21 +0200'),
                :date_time_original => Time.parse('2014-06-19 15:47:09 +0200'),
                :gps_altitude => nil,
                :gps_longitude => 8.747413888888888,
                :gps_latitude => 42.04863611111111,
                :exposure_time => Rational(1,640),
                :focal_length => Rational(18),
                :f_number => Rational(11)
            )
        end
    end
end
