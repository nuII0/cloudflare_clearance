RSpec.describe CloudflareClearance::Drivers, :drivers do
  describe ".autodetect" do
    context "driver available" do
      let (:driver) do
        Class.new do
          def self.available?
            true
          end
          def self.deprecated?
            false
          end
        end
      end
      it "returns available driver" do
        described_class.drivers = [ driver ]

        expect(described_class.autodetect).to eq(driver)
      end
    end

    context "no driver available" do
      it "raises" do
        described_class.drivers = []
        expect{described_class.autodetect}.to raise_error(CloudflareClearance::DriverUnavailable)
      end
    end
  end
end
