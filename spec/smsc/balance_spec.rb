RSpec.describe SMSC::Balance do
  describe "#call" do
    context "CONNECTION_REFUSED" do
      it "returns error" do
        stub_request(:post, "https://smsc.kz/sys/balance.php").to_raise(Errno::ECONNREFUSED)
        request = SMSC::Balance.new(login: "login", password: "password")
        expect(request.call.value).to eq(:network_error)
      end
    end

    context "wrong credentials" do
      it "returns error" do
        stub_request(:post, "https://smsc.kz/sys/balance.php").to_return(body: File.new('spec/smsc/fixtures/wrong_credentials.json'), status: 200)
        request = SMSC::Balance.new(login: "login", password: "password")
        expect(request.call.value).to eq(:authorize_error)
      end
    end

    context "valid data" do
      it "returns data on success request" do
        stub_request(:post, "https://smsc.kz/sys/balance.php").to_return(body: File.new('spec/smsc/fixtures/balance.json'), status: 200)
        request = SMSC::Balance.new(login: "login", password: "password")
        expect(request.call.value).to eq({ balance: "0.00", currency: "KZT" })
      end
    end
  end
end
