# frozen_string_literal: true

require "thor_enhance/autogenerate"
require 'ostruct'

RSpec.describe ThorEnhance::Autogenerate::Validate do
  let(:options) { OpenStruct.new(subcommand: subcommand, command: command, executable: executable, root: root) }
  let(:subcommand) { nil }
  let(:command) { nil }
  let(:executable) { nil }
  let(:root) { nil }

  describe ".validate" do
    subject { described_class.validate(options: options, root: root_klass) }
    let(:root_klass) { MyTestClass }

    it do
      expect(subject[:status]).to eq(:pass)
    end

    context "when root provided" do
      context "when root is not a thor object" do
        let(:root_klass) { String }

        it do
          expect(subject[:status]).to eq(:fail)
        end
      end

      context "when exists" do
        let(:root) { "MyTestClass" }
        let(:root_klass) { nil }

        it do
          expect { subject }.to_not raise_error
        end
      end

      context "when does not exist" do
        let(:root) { "Undefined klass" }
        let(:root_klass) { nil }
        it do
          expect { subject }.to_not raise_error
        end

        it do
          expect(subject[:status]).to eq(:fail)
        end
      end
    end

    context "when subcommand provided" do
      let(:subcommand) { ["sub"] }

      it do
        expect(subject[:status]).to eq(:pass)
      end

      context "with bad subcommand" do
        let(:subcommand) { ["subordinate"] }

        it do
          expect(subject[:status]).to eq(:fail)
        end
      end
    end

    context "when command provided" do
      let(:command) { "test_meth" }

      it do
        expect(subject[:status]).to eq(:pass)
      end

      context "with bad command" do
        let(:command) { "unknown" }

        it do
          expect(subject[:status]).to eq(:fail)
        end
      end
    end
  end
end
