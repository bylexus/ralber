require 'rubygems'
require 'bundler/setup'

require 'ralbum/template'
require 'json'

RSpec.describe Ralbum::Template do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))
        @template1 = File.join(@fixpath,'template1')
        @template2 = File.join(@fixpath,'template2')
        @template3 = File.join(@fixpath,'template3')
    end

    after(:example) do
    end

    describe "#initialize" do
        it "should initialize with a correct template path" do
            tpl = Ralbum::Template.new(@template1)
            expect(tpl).to_not eq(nil)
            expect(tpl.path).to eq(@template1)
            expect(tpl.config).to include("image_dir"=>"images")
        end
    end

    describe "#read_config" do
        it "should read the template values from template.json" do
            tpl = Ralbum::Template.new(@template1)
            conf = tpl.read_config
            expect(conf).to include("image_dir"=>"images")
        end
        it "should throw an exeption if the template.json cannot be read" do
            expect{
                tpl = Ralbum::Template.new(@template2)
                tpl.read_config
            }.to raise_error
        end
    end

    describe "#images_config" do
        it "should check and return the image config from the template" do
            tpl = Ralbum::Template.new(@template1)
            conf = tpl.images_config
            expect(conf).to include('thumb')
            expect(conf).to include('detail')
        end
        it "should raise an error if the images config is not present" do
            tpl = Ralbum::Template.new(@template3)
            expect { 
                conf = tpl.images_config
            }.to raise_error
        end
    end

end
