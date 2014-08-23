require 'lib/Image'
require 'json'
RSpec.describe Image do
    before(:example) do
        @fixpath = File.expand_path(File.join(File.dirname(__FILE__),'..','fixtures','testalbum1'))
    end

    after(:example) do
    end


    it "raises an error if the given path is no file" do
        expect{Image.new('/some/path/to/nowhere')}.to raise_error
    end
        
    it "initializes with the given path" do
        image = Image.new(File.join(@fixpath,'image1.png'))
        expect(image.path).to eq(File.join(@fixpath,'image1.png'))
    end
end
