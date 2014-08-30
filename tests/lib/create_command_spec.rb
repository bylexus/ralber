require 'rubygems'
require 'bundler/setup'

require 'lib/create_command'
require 'commander/import'
require 'tmpdir'

program :version, '0.0.1'
program :description, 'dummy'

RSpec.describe Ralbum::Commands::Create do
    before(:example) do
    end

    after(:example) do
    end

    describe "#initialize" do
        it "should take args and options as arguments" do
            p = Ralbum::Commands::Create.new([1,"2"],Commander::Command::Options.new)
            expect(p).to be
        end
    end
end
