# frozen_string_literal: true

require "thor_enhance/autogenerate"

RSpec.describe ThorEnhance::Autogenerate do
  subject { described_class.execute!(options: options, root: root) }

  before do
    allow(described_class::Validate).to receive(:validate).and_return(validate_result)
  end
  let(:options) { OpenStruct.new(subcommand: subcommand, command: command, root: root) }
  let(:root) { nil }
  let(:back_uproot) { MyTestClass }
  let(:subcommand) { nil }
  let(:command) { nil }

  let(:validate_result) do
    {
      command: nil,
      constant: nil,
      msg_array: ["some", "message"],
      status: validate_status,
      trunk: nil,
    }
  end
  let(:validate_status) { :pass }

  context "with validate failure" do
    let(:validate_status) { :fail }

    it "calls downstream" do
      expect(subject[:status]).to eq(:fail)
    end
  end

  it "calls downstream" do
    expect(subject[:status]).to eq(:pass)
  end
end
