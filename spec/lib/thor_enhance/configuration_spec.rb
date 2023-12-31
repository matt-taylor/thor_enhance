# frozen_string_literal: true

require "thor_enhance/autogenerate"

RSpec.describe ThorEnhance::Configuration do
  let(:instance) { described_class.new }

  before { described_class.class_variable_set("@@allow_changes", nil) }
  let(:random_chars) { (("A".."Z").to_a +  ("a"..."z").to_a).shuffle[0..20].join }

  describe ".allow_changes?" do
    subject { described_class.allow_changes?(raise_error: raises) }
    let(:raises) { true }

    it { is_expected.to eq(true) }

    context "when disabled" do
      before { described_class.disallow_changes! }

      context "when not raising" do
        let(:raises) { false }
        it { is_expected.to eq(false) }
      end

      it do
        expect { subject }.to raise_error(ThorEnhance::BaseError, /Configuration changes are halted/)
      end
    end
  end

  describe "#add_command_method_enhance" do
    subject { instance.add_command_method_enhance(name, **params) }

    let(:params) do
      {
        allowed_klasses: allowed_klasses,
        arity: arity,
        enums: enums,
        optional_kwargs: optional_kwargs,
        repeatable: repeatable,
        required: required,
        required_kwargs: required_kwargs,
      }
    end
    let(:name) { "some_name_#{random_chars}" }
    let(:allowed_klasses) { nil }
    let(:enums) { nil }
    let(:required) { false }
    let(:repeatable) { false }
    let(:arity) { 0 }
    let(:required_kwargs) { [] }
    let(:optional_kwargs) { [] }

    context "when invalid type" do
      let(:name) { 1 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Invalid name type received/)
      end
    end

    context "when invalid name" do
      let(:name) { ".wfwa3145" }

      it do
        expect { subject }.to raise_error(ArgumentError, /Invalid name received/)
      end
    end

    context "when already defined" do
      let(:name) { ::Thor::Command.instance_methods.select { _1 =~ /^[A-Za-z_]+$/ }.sample }

      it do
        expect { subject }.to raise_error(ThorEnhance::OptionNotAllowed, /is not allowed as an enhancement/)
      end
    end

    context "when duplicate" do
      before { instance.add_command_method_enhance(name) }

      it do
        expect { subject }.to raise_error(ThorEnhance::OptionNotAllowed, /Duplicate detected/)
      end
    end

    context "when incorrect enums" do
      let(:enums) { 5 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Recieved enums with/)
      end
    end

    context "when incorrect klasses" do
      let(:allowed_klasses) { 5 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Recieved allowed_klasses with/)
      end
    end

    context "when incorrect arity" do
      let(:arity) { -1 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Recieved arity with/)
      end
    end

    it "adds storage" do
      subject

      expect(instance.command_method_enhance[name.to_sym]).to be_a(Hash)
    end
  end

  describe "#add_option_enhance" do
    subject { instance.add_option_enhance(name, allowed_klasses: allowed_klasses, enums: enums) }

    let(:allowed_klasses) { nil }
    let(:enums) { nil }
    let(:name) { "some_name_#{random_chars}" }

    context "when incorrect enums" do
      let(:enums) { 5 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Recieved enums with/)
      end
    end

    context "when incorrect klasses" do
      let(:allowed_klasses) { 5 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Recieved allowed_klasses with/)
      end
    end

    context "when invalid type" do
      let(:name) { 1 }

      it do
        expect { subject }.to raise_error(ArgumentError, /Invalid name type received/)
      end
    end

    context "when invalid name" do
      let(:name) { ".wfwa3145" }

      it do
        expect { subject }.to raise_error(ArgumentError, /Invalid name received/)
      end
    end

    context "when already defined" do
      let(:name) { ::Thor::Option.instance_methods.select { _1 =~ /^[A-Za-z_]+$/ }.sample }

      it do
        expect { subject }.to raise_error(ThorEnhance::OptionNotAllowed, /is not allowed as an enhancement/)
      end
    end

    context "when duplicate" do
      before { instance.add_option_enhance(name) }

      it do
        expect { subject }.to raise_error(ThorEnhance::OptionNotAllowed, /Duplicate detected/)
      end
    end

    it "adds storage" do
      subject

      expect(instance.option_enhance[name.to_sym]).to be_a(Hash)
    end
  end

  describe "#readme_enhance!" do
    before { ENV["SKIP_TESTING_METHOD"] = "true" }
    subject { instance.readme_enhance! }

    before do
      allow(::Thor::Command).to receive(:instance_methods).and_return([])
    end

    it "defines readme options" do
      expect(instance).to receive(:add_command_method_enhance).at_least(3)
      expect(instance).to receive(:add_option_enhance).once

      subject
    end

    it "returns block correctly" do
      instance.readme_enhance! do |c|
        expect(c).to be_a(ThorEnhance::Autogenerate::Configuration)
      end
    end

    context "when called multiple times" do
      before { instance.autogenerated_config }

      it do
        expect { subject }.to raise_error(ThorEnhance::ValidationFailed, /ReadMe Enhance has already been initialized/)
      end
    end
  end

  describe "allowed=" do
    subject { instance.allowed = allowed }

    let(:allowed) { described_class::ALLOWED_VALUES.sample }

    context "when not allowed" do
      let(:allowed) { (super().to_s + "#{rand(10_000..99_999)}")}

      it do
        expect { subject }.to raise_error(ArgumentError, /Unexpected value for `allowed =`/)
      end
    end
  end

  describe "basename | basename = " do
    let(:basename) { "Some Random String #{rand(10_000..99_999)}" }
    it "sets basename" do
      instance.basename = basename

      expect(instance.basename).to eq(basename)
    end
  end
end
