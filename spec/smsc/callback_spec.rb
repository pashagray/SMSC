RSpec.describe SMSC::Callback do
  describe "#call" do
    context "block is not given" do
      it "returns transformed hash" do
        callback = SMSC::Callback.new
        result = callback.call({ id: 1 })
        expect(result).to eq({ id: 1 })
      end

      it "transformes status" do
        callback = SMSC::Callback.new
        result = callback.call({ id: 1, status: "1" })
        expect(result).to eq({ id: 1, status: :delivered })
      end

      it "trasforms error" do
        callback = SMSC::Callback.new
        result = callback.call({ id: 1, err: "1" })
        expect(result).to eq({ id: 1, err: :sub_not_exist })
      end
    end

    context "block is given" do
      it "passes transformed hash to block" do
        callback = SMSC::Callback.new
        result = callback.call({ id: 1, status: "1" }) { |params| params[:status] }
        expect(result).to eq(:delivered)
      end
    end
  end
end
