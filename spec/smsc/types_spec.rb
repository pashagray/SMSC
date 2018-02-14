RSpec.describe SMSC::Types do
  describe "Phone" do
    it "transforms value to digit-only string" do
      expect(SMSC::Types::Phone["+7 (777) 888-77-66"]).to eq("77778887766")
    end
  end

  describe "Fmt" do
    context "value is 3" do
      it "satisfy requirements" do
        expect(SMSC::Types::Fmt[3]).to eq(3)
      end
    end

    context "value is not 3" do
      it "raises error" do
        expect { SMSC::Types::Fmt[1] }.to raise_error(Dry::Types::ConstraintError)
      end
    end
  end

  describe "Cur" do
    context "value is 1" do
      it "satisfy requirements" do
        expect(SMSC::Types::Cur[1]).to eq(1)
      end
    end

    context "value is not 1" do
      it "raises error" do
        expect { SMSC::Types::Cur[0] }.to raise_error(Dry::Types::ConstraintError)
      end
    end
  end

  describe "Password" do
    it "converts value to MD5" do
      expect(SMSC::Types::Password["abc"]).to eq("900150983cd24fb0d6963f7d28e17f72")
    end
  end

  describe "OnOff" do
    context "when true" do
      it "returns 1" do
        expect(SMSC::Types::OnOff[true]).to eq("1")
      end
    end

    context "when false" do
      it "returns 0" do
        expect(SMSC::Types::OnOff[false]).to eq("0")
      end
    end

    context "when not a TrueClass/FalseClass" do
      it "raises error" do
        expect { SMSC::Types::OnOff[:wrong] }.to raise_error(Dry::Types::ConstraintError)
        expect { SMSC::Types::OnOff[1] }.to raise_error(Dry::Types::ConstraintError)
        expect { SMSC::Types::OnOff[0] }.to raise_error(Dry::Types::ConstraintError)
        expect { SMSC::Types::OnOff["1"] }.to raise_error(Dry::Types::ConstraintError)
        expect { SMSC::Types::OnOff["0"] }.to raise_error(Dry::Types::ConstraintError)
        expect { SMSC::Types::OnOff["true"] }.to raise_error(Dry::Types::ConstraintError)
        expect { SMSC::Types::OnOff["false"] }.to raise_error(Dry::Types::ConstraintError)
      end
    end
  end
end
