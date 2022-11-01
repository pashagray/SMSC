RSpec.describe SMSC::Status do
  describe "#call" do
    context "CONNECTION_REFUSED" do
      it "returns error" do
        stub_request(:post, "https://smsc.ru/sys/status.php").to_raise(Errno::ECONNREFUSED)
        request = SMSC::Status.new(login: "login", password: "password")
        expect(request.call(phone: "87776663322", message_id: 1).failure).to eq(:network_error)
      end
    end

    context "wrong credentials" do
      it "returns error" do
        stub_request(:post, "https://smsc.ru/sys/status.php").to_return(body: File.new('spec/smsc/fixtures/wrong_credentials.json'), status: 200)
        request = SMSC::Status.new(login: "login", password: "password")
        expect(request.call(phone: "87776663322", message_id: 1).failure).to eq(:wrong_credentials)
      end
    end
    context "valid data" do
      it "returns data on success request" do
        stub_request(:post, "https://smsc.ru/sys/status.php").to_return(body: File.new('spec/smsc/fixtures/status.json'), status: 200)
        request = SMSC::Status.new(login: "login", password: "password")
        expected = {
          cost: 6.4,
          country: "Казахстан",
          message: "Test",
          operator: "K'cell",
          phone: "77014929242",
          region: "",
          send_timestamp: Time.parse("2018-02-12 18:34:17.000000000 +0600"),
          sender_id: "SMSC.KZ",
          status: :delivered,
          type: :sms
        }
        expect(request.call(phone: "87776663322", message_id: 1).value!).to eq(expected)
      end
    end
  end
end
