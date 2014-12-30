require 'rubygems'
require 'bundler/setup'

require 'ralber/template'
require 'json'

RSpec.describe Ralber::Template do
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
            tpl = Ralber::Template.new(@template1)
            expect(tpl).to_not eq(nil)
            expect(tpl.path).to eq(@template1)
            expect(tpl.config).to include("image_dir"=>"images")
        end
    end

    describe "#read_config" do
        it "should read the template values from template.json" do
            tpl = Ralber::Template.new(@template1)
            conf = tpl.read_config
            expect(conf).to include("image_dir"=>"images")
        end
        it "should throw an exeption if the template.json cannot be read" do
            expect{
                tpl = Ralber::Template.new(@template2)
                tpl.read_config
            }.to raise_error
        end
    end

    describe "#images_config" do
        it "should check and return the image config from the template" do
            tpl = Ralber::Template.new(@template1)
            conf = tpl.images_config
            expect(conf).to include('thumb')
            expect(conf).to include('detail')
        end
        it "should raise an error if the images config is not present" do
            tpl = Ralber::Template.new(@template3)
            expect { 
                conf = tpl.images_config
            }.to raise_error
        end
    end

    describe "#find" do
        it "should return the default template if nil is given" do
            tpl = Ralber::Template.find(nil)
            path = File.expand_path(File.join(File.dirname(Gem.bin_path('ralber','ralber.rb')),'..','templates','default'))
            expect(tpl.path).to eq(path)
        end

        it "should return the fancybox template if 'fancybox-dark' is given" do
            tpl = Ralber::Template.find('fancybox-dark')
            path = File.expand_path(File.join(File.dirname(Gem.bin_path('ralber','ralber.rb')),'..','templates','fancybox-dark'))
            expect(tpl.path).to eq(path)
        end

        it "should return an external template if specified by path" do
            tpl = Ralber::Template.find(@template1)
            path = File.expand_path(@template1)
            expect(tpl.path).to eq(path)
        end

        it "should raise an exception if template could not be found" do
            expect {
                Ralber::Template.find('xxxxxx')
            }.to raise_error
        end
    end

    describe "#bundled_templates" do
        it "should return a hash with name => path to available bundled templates" do
            tpls = Ralber::Template.bundled_templates
            expect(tpls).to include({:name => 'default', :path => File.join(Ralber::Template.template_path,'default')})
            expect(tpls).to include({:name => 'fancybox-dark', :path => File.join(Ralber::Template.template_path,'fancybox-dark')})
        end
    end

end
