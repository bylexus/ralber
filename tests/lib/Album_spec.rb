require 'rubygems'
require 'bundler/setup'

require 'lib/Album'
require 'json'
RSpec.describe Album do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures','testalbum1'))
    end

    after(:example) do
       File.delete(File.join(@fixpath,'album.json')) if File.exists?(File.join(@fixpath,'album.json'))
    end

    it "initializes with the given path" do
        album = Album.new('/some/path')
        expect(album.path).to eq('/some/path')
    end

    it "has an images getter" do
        album = Album.new(@fixpath)
        expect(album).to respond_to(:images)
    end


    describe "#album_json_path" do
        it "returns the path to the album json file" do
            album = Album.new(@fixpath)
            expect(album.album_json_path).to eq(File.join(File.expand_path(@fixpath),'album.json'))
        end
    end


    describe "#create" do
        it "exists as a function" do
            album = Album.new
            expect(album).to respond_to(:create)
        end

        it "raises an exception if the album dir does not exists" do
            album = Album.new('/unknown/path')
            expect { album.create }.to raise_error
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
            jsonfile = File.read(album.album_json_path)
            obj = JSON.parse(jsonfile)
            expect(obj).to include("path"=>@fixpath)
            expect(obj).to include("title"=>File.basename(@fixpath))
        end
    end

end
