RSpec.describe CloudflareClearance::Clearance do
  describe "#initialize" do
    let(:driver_mock) { mock_generic_webdriver }

    context "bare string as url" do
      let(:url) { "not_a_http_url" }
      it "raises" do
        expect{described_class.new(url, driver: driver_mock)}.to raise_error(ArgumentError)
      end
    end

    context "ftp url" do
      let(:url) { "ftp://incorrect.local" }
      it "raises" do
        expect{described_class.new(url, driver: driver_mock)}.to raise_error(ArgumentError)
      end
    end

    context "http url" do
      let(:url) { "http://example.local" }
      it "returns clearance data" do
        expect(described_class.new(url, driver: driver_mock).clearance_data).to eq(VALID_CLEARANCE_DATA)
      end
    end

    context "https url" do
      let(:url) { "https://example.local" }
      it "returns clearance data" do
        expect(described_class.new(url, driver: driver_mock).clearance_data).to eq(VALID_CLEARANCE_DATA)
      end
    end

  end
end
