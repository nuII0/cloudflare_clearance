# frozen_string_literal: true
#require 'ostruct'
#RSpec.describe CloudflareClearance::Driver::ExecJS do
  #describe '.get_cookie' do
    #context 'if working adapter is given' do
      #it 'generates a http cookie' do
        #testadapter = double
        #allow(testadapter).to receive(:get).and_return(
          #OpenStruct.new.tap do |struct|
            #struct.header = { "Set-Cookie" => "__cfduid=foobar" }
            #struct.body = File.read(File.dirname(__FILE__) + '/../fixture/valid_input.html')
          #end,
          #OpenStruct.new.tap{|struct| struct.header = { "Set-Cookie" => "cf_clearance=barbaz" }}
        #)
        #challenge = double
        #allow(challenge).to receive(:solve){ { foo: 'bar', baz: 'baz' } }
        #clearance = described_class.get_clearance('http://www.example.com', adapter: testadapter, challenge: challenge)

        #expect(clearance.cookies.to_s).to eq("cf_clearance=barbaz")
      #end
    #end
  #end
#end
