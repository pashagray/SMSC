RSpec.describe SMSC::Balance do
  describe "#call" do
    it "returns error on CONNECTION_REFUSED" do
      stub_request(:post, "https://smsc.kz/sys//balance.php").to_raise(Errno::ECONNREFUSED)
      request = SMSC::Balance.new(login: "login", psw: "password")
      expect(request.call).to eq({ error: :network })
    end

    context "wrong credentials" do
      it "returns error" do
        stub_request(:post, "https://smsc.kz/sys//balance.php").to_return(body: File.new('spec/smsc/fixtures/wrong_credentials.json'), status: 200)
        request = SMSC::Balance.new(login: "login", psw: "password")
        expect(request.call).to eq({ error: :authorize })
      end
    end

    context "valid data" do
      it "returns data on success request" do
        stub_request(:post, "https://smsc.kz/sys//balance.php").to_return(body: File.new('spec/smsc/fixtures/balance.json'), status: 200)
        request = SMSC::Balance.new(login: "login", psw: "password")
        expect(request.call).to eq({ balance: "0.00", currency: "KZT" })
      end
    end
  end
end
