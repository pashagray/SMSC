RSpec.describe SMSC do
  describe ".configure" do
    around do |example|
      original_login = described_class.config.login
      original_password = described_class.config.password

      example.run
    ensure
      described_class.configure do |config|
        config.login = original_login
        config.password = original_password
      end
    end

    it "provides configured credentials to API requests by default" do
      described_class.configure do |config|
        config.login = "configured-login"
        config.password = "configured-password"
      end

      request = stub_request(:post, "https://smsc.ru/sys/balance.php")
        .with(body: hash_including(
          "login" => "configured-login",
          "psw" => "configured-password"
        ))
        .to_return(body: '{"balance":"0.00","currency":"KZT"}', status: 200)

      expect(SMSC::Balance.new.call).to be_success
      expect(request).to have_been_requested.once
    end
  end
end
