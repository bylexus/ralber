require 'rubygems'
require 'bundler/setup'

require 'lib/Album'
require 'lib/Image'
require 'json'
RSpec.describe Album do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures','testalbum1'))
        @fixpath_existing = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures','testalbum2'))
    end

    after(:example) do
        Dir.glob(File.join(@fixpath,'*.json')).each { |f| File.delete(f) }
    end

    it "initializes with the given path" do
        album = Album.new(@fixpath)
        expect(album.path).to eq(@fixpath)
    end

    it "raises an exception if the album dir does not exists" do
        expect { Album.new('/unknown/path') }.to raise_error
    end


    it "has an images getter" do
        album = Album.new(@fixpath)
        expect(album).to respond_to(:images)
    end

    describe "#initialize" do
        it "should have initialized the album info and the images for a new album" do
            album = Album.new(@fixpath)
            expect(album.title).to eq("testalbum1")
            expect(album.subtitle).to eq("")
            expect(album.description).to eq("")
            expect(album.images.length).to eq(0)
        end

        it "should have loaded the album info for an existing album" do
            album = Album.new(@fixpath_existing)
            expect(album.title).to eq("My test album")
            expect(album.subtitle).to eq("A subtitle")
            expect(album.description).to eq("A description")
            expect(album.images.length).to eq(2)

        end
    end


    describe "#json_path" do
        it "returns the path to the album json file" do
            album = Album.new(@fixpath)
            expect(album.json_path).to eq(File.join(File.expand_path(@fixpath),'album.json'))
        end
    end

    describe "#get_new_info" do
        it "should return a new, empty album info object" do
            album = Album.new(@fixpath)
            ret = album.get_new_info
            expect(ret['title']).to eq('testalbum1')
            expect(ret['subtitle']).to eq('')
            expect(ret['description']).to eq('')
            expect(ret['images'].length).to eq(0)
        end
    end

    describe "#get_album_info" do
        it "should return an empty album info for an uninitialized album" do
            album = Album.new(@fixpath)
            ret = album.get_album_info
            expect(ret['title']).to eq('testalbum1')
            expect(ret['subtitle']).to eq('')
            expect(ret['description']).to eq('')
            expect(ret['images'].length).to eq(0)
        end
        it "should return the album info for an existing album" do
            album = Album.new(@fixpath_existing)
            ret = album.get_album_info
            expect(ret['title']).to eq('My test album')
            expect(ret['subtitle']).to eq('A subtitle')
            expect(ret['description']).to eq('A description')
            expect(ret['images'].length).to eq(2)
            expect(ret['images'][0]).to eq("2004-04-12 09-10-15 6928.jpg")
        end
    end

    describe "#create" do
        it "exists as a function" do
            album = Album.new(@fixpath)
            expect(album).to respond_to(:create)
        end

        it "creates a album.json file within the album dir" do
            path = @fixpath
            album = Album.new(path)
            album.create
            expect(File.exists?(File.join(@fixpath,'album.json'))).to be_truthy
        end

        it "fills in the default values into album.json" do
            path = @fixpath
            album = Album.new(path)
            album.create
            jsonfile = File.read(album.json_path)
            obj = JSON.parse(jsonfile)
            expect(obj).to include("title"=>File.basename(@fixpath))
            expect(obj).to include("subtitle"=>'')
            expect(obj).to include("description"=>'')
            expect(obj).to include("images"=>["2004-04-12 09-10-15 6928.jpg", "2004-06-20 11-07-53 6931.jpg"])
        end

        it "invokes the create function on each image associated" do
            album = Album.new(@fixpath)
            album.create
            expect(album.images.length).to eq(2)
            album.images.each do |img|
                expect(File.exists?(img.json_path)).to be_truthy
            end
        end
    end

    describe "#collect_images" do
        it "should respond" do
            album = Album.new(@fixpath)
            expect(album).to respond_to(:collect_images)
        end

        it "should return an array of Image objects, containing the images given" do
            album = Album.new(@fixpath)
            album.create
            images = album.collect_images(["2004-04-12 09-10-15 6928.jpg","2004-06-20 11-07-53 6931.jpg","2005-01-30 11-10-00 6933.jpg"],@fixpath)
            expect(images).to be_kind_of(Array)
            expect(images.length).to eq(2)
            expect(images[0]).to be_kind_of(Image)
            expect(images[0].type).to eq(:jpeg)
        end
    end
end
