# frozen_string_literal: true

require "thor_enhance/autogenerate"

RSpec.describe ThorEnhance::Autogenerate::Configuration do
  let(:instance) { described_class.new }

  before { ThorEnhance::Configuration.class_variable_set("@@allow_changes", nil) }

  describe "#default" do
    subject { instance.default }

    context "when disabled" do
      before { ThorEnhance::Configuration.disallow_changes! }

      it do
        expect { subject }.to raise_error(ThorEnhance::BaseError, /Configuration changes are halted/)
      end
    end

    context "when required is true" do
      before { instance.set_default_required(true) }

      it do
        subject

        expect(instance.configuration[:add_command_method_enhance][:example][:required]).to eq(true)
        expect(instance.configuration[:add_option_enhance][:readme][:required]).to eq(true)
      end
    end

    it do
      expect { subject }.to_not raise_error
    end

    it do
      expect(instance).to receive(:example).and_call_original
      expect(instance).to receive(:readme).and_call_original

      subject
    end

    it do
      subject

      expect(instance.configuration[:add_command_method_enhance][:example][:required]).to eq(false)
      expect(instance.configuration[:add_option_enhance][:readme][:required]).to eq(false)
    end
  end

  describe "#example" do
    subject { instance.example(required: required, repeatable: repeatable) }
    let(:required) { nil }
    let(:repeatable) { false }

    it do
      subject

      expect(instance.configuration[:add_command_method_enhance][:example][:required]).to eq(false)
    end

    it do
      subject

      expect(instance.configuration[:add_command_method_enhance][:example][:repeatable]).to eq(false)
    end

    context "when required is set" do
      context "when set via default required" do
        before { instance.set_default_required(true) }

        it do
          subject

          expect(instance.configuration[:add_command_method_enhance][:example][:required]).to eq(true)
        end
      end

      context "when false" do
        let(:required) { false }

        it do
          subject

          expect(instance.configuration[:add_command_method_enhance][:example][:required]).to eq(false)
        end
      end

      context "when true" do
        let(:required) { true }

        it do
          subject

          expect(instance.configuration[:add_command_method_enhance][:example][:required]).to eq(true)
        end
      end
    end

    context "when repeatable is set" do
      let(:repeatable) { true }

      it do
        subject

        expect(instance.configuration[:add_command_method_enhance][:example][:repeatable]).to eq(true)
      end
    end
  end

  describe "#readme" do
    subject { instance.readme(**{ required: required, enums: enums }.compact) }
    let(:required) { nil }
    let(:enums) { nil }

    it do
      subject

      expect(instance.configuration[:add_option_enhance][:readme][:required]).to eq(false)
    end

    it do
      subject

      expect(instance.configuration[:add_option_enhance][:readme][:enums]).to eq([:important, :advanced, :skip])
    end

    context "when required is set" do
      context "when set via default required" do
        before { instance.set_default_required(true) }

        it do
          subject

          expect(instance.configuration[:add_option_enhance][:readme][:required]).to eq(true)
        end
      end

      context "when false" do
        let(:required) { false }

        it do
          subject

          expect(instance.configuration[:add_option_enhance][:readme][:required]).to eq(false)
        end
      end

      context "when true" do
        let(:required) { true }

        it do
          subject

          expect(instance.configuration[:add_option_enhance][:readme][:required]).to eq(true)
        end
      end
    end

    context "when enums is set" do
      let(:enums) { [:custom_enums, :are_present] }

      it do
        subject

        expect(instance.configuration[:add_option_enhance][:readme][:enums]).to eq(enums)
      end
    end
  end
end
