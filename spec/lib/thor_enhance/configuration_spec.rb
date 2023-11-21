# frozen_string_literal: true

RSpec.describe ThorEnhance::Configuration do
  let(:instance) { described_class.new }

  before { described_class.class_variable_set("@@allow_changes", nil) }
  let(:random_chars) { (("A".."Z").to_a +  ("a"..."z").to_a).shuffle[0..20].join }

  describe "#add_command_method_enhance" do
    subject { instance.add_command_method_enhance(name, allowed_klasses: allowed_klasses, enums: enums) }

    let(:allowed_klasses) { nil }
    let(:enums) { nil }
    let(:name) { "some_name_#{random_chars}" }

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
end
