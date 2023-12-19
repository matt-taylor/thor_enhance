# frozen_string_literal: true

require "thor_enhance/autogenerate"

RSpec.describe ThorEnhance::Autogenerate do
  subject { described_class.execute!(options: options, root: root) }

  let(:options) { OpenStruct.new(subcommand: subcommand, command: command, root: root) }
  let(:root) { MyTestClass }
  let(:subcommand) { nil }
  let(:command) { nil }

  let(:validate_status) { :pass }

  context "with validate failure" do
    let(:root) { nil }

    it "calls downstream" do
      expect(subject[:status]).to eq(:fail)
    end
  end

  context "with command" do
    let(:command) { "test_meth" }

    it do
      expect { subject }.to_not raise_error
    end

    it do
      expect(subject[:status]).to eq(:pass)
    end
  end

  context "with subcommand" do
    let(:subcommand) { ["sub"] }

    it do
      expect { subject }.to_not raise_error
    end

    it do
      expect(subject[:status]).to eq(:pass)
    end
  end

  it "calls downstream" do
    expect(subject[:status]).to eq(:pass)
  end
end
