RSpec.describe CloudflareClearance::ExecJs, :exec_js do


  describe "#initialize" do
    it "initializes" do
      expect{self}.not_to raise_error
    end
  end

  describe "#get_clearance" do

    let(:test_url) { "http://foo.local" }
    let(:no_timeout) { 0 }

    # Mock a HTTP GET Request and return whatever is defined
    # in first_response.
    let(:http_mock) do
      double.tap do |d|
        allow(d).to receive(:get).and_return(first_response)
      end
    end

    subject { described_class.new(http_adapter: http_mock) }

    context "receives empty header cookie" do
      let(:first_response) do
        double.tap do |d|
          allow(d).to receive(:header).and_return(
            Hash.new )
        end
      end

      it "raises" do
        expect{subject.get_clearance(test_url)}.to raise_error(CloudflareClearance::ClearanceError)
      end
    end

    context "receives no challenge cookie" do
      let(:first_response) do
        double.tap do |d|
          allow(d).to receive(:header).and_return(
            {"Set-Cookie" => ""})
        end
      end

      it "raises" do
        expect{subject.get_clearance(test_url)}.to raise_error(CloudflareClearance::ClearanceError)
      end
    end

    context "receives invalid challenge" do
      let(:first_response) do
        double.tap do |d|
          allow(d).to receive(:header).and_return(
            {"Set-Cookie": VALID_CFUID_COOKIE})
          allow(d).to receive(:body).and_return(
            file_fixture("invalid_challenge.html").read
          )
        end
      end

      it "raises" do
        expect{subject.get_clearance(test_url)}.to raise_error(CloudflareClearance::ClearanceError)
      end
    end

    context "receives correct challenge" do

      # A correct challenge sets the CFUID cookie
      # in the header and provides a valid javascript
      # challenge.
      let(:first_response) do
        double.tap do |d|
          allow(d).to receive(:header).and_return(
            {"Set-Cookie" => VALID_CFUID_COOKIE})
          allow(d).to receive(:body).and_return(
            file_fixture("valid_challenge.html").read
          )
        end
      end

      # Mock two subsequent HTTP GET calls where the first
      # responses a valid challenge.
      # The second call returns whatever is currently tested.
      let(:http_mock) { double.tap do |d|
        allow(d).to receive(:get).and_return(first_response, second_response)
      end
      }

      context "receives no session cookie" do
        let(:second_response) do
          double.tap do |d|
            allow(d).to receive(:header).and_return(
              {"Set-Cookie" => ""})
          end
        end
        it "raises" do
          expect{subject.get_clearance(test_url)}.to raise_error(CloudflareClearance::ClearanceError)
        end
      end

      context "receives session cookie" do
        let(:second_response) do
          double.tap do |d|
            allow(d).to receive(:header).and_return(
              {"Set-Cookie"=> VALID_CF_CLEARANCE_COOKIE})
          end
        end

        it "returns Clearance" do
          expect(subject.get_clearance(test_url)).to be_instance_of(CloudflareClearance::Clearance)
        end
      end
    end
  end
end

