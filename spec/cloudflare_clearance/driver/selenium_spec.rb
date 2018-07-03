RSpec.describe CloudflareClearance::Selenium do
  describe "#initialize" do
    it "initializes" do
      expect{self}.not_to raise_error
    end
  end

  describe "#get_clearance" do
    let(:driver_mock) { mock_selenium_webdriver(cookies) }
    let(:url) { "http://foo.local" }
    let(:none) { 0 }
    subject { described_class.new(selenium_webdriver: driver_mock) }

    context "receives cf cookies" do
      let(:clearance_data) { VALID_CLEARANCE_DATA }
      let(:cookies) { [VALID_CFUID_COOKIE, VALID_CF_CLEARANCE_COOKIE] }
      it "returns clearance data" do
        expect(subject.get_clearance(url,retries: none, seconds_wait_retry: none)).to eq(clearance_data)
      end
    end

    #context "receives cf cookies and others" do
      #let(:cookieset) { [VALID_CFUID_COOKIE, VALID_CF_CLEARANCE_COOKIE, OTHER_COOKIE] }
      #it "returns cf cookies" do
        #other_cookie_not_included = cookies.dup.tap { |h| h.delete(OTHER_COOKIE) }
        #expect(subject.get_clearance(url,retries: none, seconds_wait_retry: none).fetch(:cookies)).to eq(other_cookie_not_included)
      #end
    #end

    context "receives no cookies" do
      let(:cookies) { [] }
      it "raises" do
        expect{ subject.get_clearance(url,retries: none, seconds_wait_retry: none) }.to raise_error(CloudflareClearance::ClearanceError)
      end
    end

    context "receives wrong cookies" do
      let(:cookies) { [INVALID_COOKIE] }
      it "raises" do
        expect{ subject.get_clearance(url,retries: none, seconds_wait_retry: none) }.to raise_error(CloudflareClearance::ClearanceError)
      end
    end

    context "receives partial cookies" do
      context "only CFUID" do
        let(:cookies) { [VALID_CFUID_COOKIE] }
        it "raises" do
          expect{ subject.get_clearance(url,retries: none, seconds_wait_retry: none) }.to raise_error(CloudflareClearance::ClearanceError)
        end
      end

      context "only CF_CLEARANCE" do
        let(:cookies) { [VALID_CF_CLEARANCE_COOKIE] }
        it "raises" do
          expect{ subject.get_clearance(url,retries: none, seconds_wait_retry: none) }.to raise_error(CloudflareClearance::ClearanceError)
        end
      end
    end

    context "timing" do
      let(:retries) { 4 }
      let(:seconds_wait_retry) { 0.1 }
      let(:delta) { 1 }
      let(:cookies) { [INVALID_COOKIE] }
      it "respects parameters" do
        t1 = Time.now
        expect { subject.get_clearance(url,retries: retries, seconds_wait_retry: seconds_wait_retry) }.to raise_error(CloudflareClearance::ClearanceError)
        time_passed = Time.now - t1
        expect(time_passed).to be_within(delta).of(retries * seconds_wait_retry)
      end
    end
  end
end
