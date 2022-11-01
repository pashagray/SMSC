RSpec.describe SMSC::Ping do
  describe "#call" do
    context "CONNECTION_REFUSED" do
      it "returns error" do
        stub_request(:post, "https://smsc.ru/sys/send.php").to_raise(Errno::ECONNREFUSED)
        request = SMSC::Ping.new(login: "login", password: "password")
        expect(request.call(phone: "87776663322").failure).to eq(:network_error)
      end
    end

    context "wrong credentials" do
      it "returns error" do
        stub_request(:post, "https://smsc.ru/sys/send.php").to_return(body: File.new('spec/smsc/fixtures/wrong_credentials.json'), status: 200)
        request = SMSC::Ping.new(login: "login", password: "password")
        expect(request.call(phone: "87776663322").failure).to eq(:wrong_credentials)
      end
    end
    context "valid data" do
      it "returns data on success request" do
        stub_request(:post, "https://smsc.ru/sys/send.php").to_return(body: File.new('spec/smsc/fixtures/send.json'), status: 200)
        request = SMSC::Ping.new(login: "login", password: "password")
        expect(request.call(phone: "87776663322").value!).to eq({ id: 1, cnt: 1, cost: 0.0, balance: 0.0 })
      end
    end
  end
end
