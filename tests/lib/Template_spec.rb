require 'rubygems'
require 'bundler/setup'

require 'lib/Template'
require 'json'

RSpec.describe Template do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures'))
        @template1 = File.join(@fixpath,'template1')
        @template2 = File.join(@fixpath,'template2')
    end

    after(:example) do
    end

    describe "#initialize" do
        it "should initialize with a correct template path" do
            tpl = Template.new(@template1)
            expect(tpl).to_not eq(nil)
            expect(tpl.path).to eq(@template1)
            expect(tpl.config).to include("image_dir"=>"images")
        end
    end

    describe "#read_config" do
        it "should read the template values from template.json" do
            tpl = Template.new(@template1)
            conf = tpl.read_config
            expect(conf).to include("image_dir"=>"images")
        end
        it "should throw an exeption if the template.json cannot be read" do
            expect{
                tpl = Template.new(@template2)
                conf = tpl.read_config
            }.to raise_error
        end

    end

end
