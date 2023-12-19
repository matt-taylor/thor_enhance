# frozen_string_literal: true

RSpec.describe ThorEnhance do
  describe "option" do
    let(:allow_option) { ThorEnhance::Configuration::ALLOW_ALL }
    around do |example|
      begin
        prev = ThorEnhance.configuration.allowed
        ThorEnhance.configuration.allowed = allow_option
        example.run
      ensure
        ThorEnhance.configuration.allowed = prev
      end
    end

    context "with missing required option" do
      let(:option) { ::Thor::Option.new("option", revoke: false) }

      it do
        expect { option }.to raise_error(ThorEnhance::RequiredOption, /does not have required option/)
      end

      context "with enhancment disabled" do
        let(:allow_option) { nil }

        it do
          expect { option }.to_not raise_error
        end
      end
    end

    context "with incorrect enum" do
      let(:option) { ::Thor::Option.new("option", classify: "unexpected") }

      it do
        expect { option }.to raise_error(ThorEnhance::ValidationFailed, /with incorrect enum/)
      end

      context "with enhancment disabled" do
        let(:allow_option) { nil }

        it do
          expect { option }.to_not raise_error
        end
      end
    end

    context "with incorrect class" do
      let(:option) { ::Thor::Option.new("option", classify: "removed", revoke: :unexpected) }

      it do
        expect { option }.to raise_error(ThorEnhance::ValidationFailed, /with incorrect class type/)
      end

      context "with enhancment disabled" do
        let(:allow_option) { nil }

        it do
          expect { option }.to_not raise_error
        end
      end
    end

    context "with missing not required option" do
      let(:option) { ::Thor::Option.new("option", classify: "allowed") }

      it do
        expect(option.classify).to eq("allowed")
        expect(option.revoke).to eq(nil)
      end
    end

    context "with good options" do
      let(:option) { ::Thor::Option.new("option", classify: "allowed", revoke: false) }

      it do
        expect(option.classify).to eq("allowed")
        expect(option.revoke).to eq(false)
      end
    end
  end

  describe "command" do
    subject { klass.new }

    context "with invalid class type" do
      let(:klass) do
        class InvalidCommandMethodKlass < Thor
          thor_enhance_allow!

          desc "test_meth", "short description"
          human_readable "required"
          counter :undefined
          def test_meth; end;
        end

        InvalidCommandMethodKlass
      end

      it do
        expect { subject }.to raise_error(ThorEnhance::ValidationFailed, /with incorrect class type/)
      end

      context "when enhance flag not set" do
        let(:klass) do
          class CommandMethodKlass < Thor
            desc "test_meth", "short description"
            human_readable "required"
            counter :undefined
            def test_meth; end;
          end

          CommandMethodKlass
        end

        it do
          expect { subject }.to_not raise_error
        end
      end
    end

    context "with invalid enum" do
      let(:klass) do
        class InvalidCommandMethodEnum < Thor
          thor_enhance_allow!

          desc "test_meth", "short description"
          human_readable "required"
          counter_enum :undefined
          def test_meth; end;
        end

        InvalidCommandMethodEnum
      end

      it do
        expect { subject }.to raise_error(ThorEnhance::ValidationFailed, /with incorrect enum/)
      end

      context "when enhance flag not set" do
        let(:klass) do
          class CommandMethodEnum < Thor
            desc "test_meth", "short description"
            human_readable "required"
            counter_enum :undefined
            def test_meth; end;
          end

          CommandMethodEnum
        end

        it do
          expect { subject }.to_not raise_error
        end
      end
    end

    context "with no input and required set" do
      let(:klass) do
        class InvalidCommandMethodRequired < Thor
          thor_enhance_allow!

          desc "test_meth", "short description"
          # human_readable "intentionally missing"
          def test_meth; end;
        end

        InvalidCommandMethodRequired
      end

      it do
        expect { subject }.to raise_error(ThorEnhance::RequiredOption, /does not have required command method/)
      end

      context "when enhance flag not set" do
        let(:klass) do
          class CommandMethodRequired < Thor

            desc "test_meth", "short description"
            # human_readable "intentionally missing"
            def test_meth; end;
          end

          CommandMethodRequired
        end

        it do
          expect { subject }.to_not raise_error
        end
      end
    end

    context "when repeated without repeatable flag set" do
      let(:klass) do
        class InvalidCommandMethodRepeatable < Thor
          thor_enhance_allow!

          desc "test_meth", "short description"
          human_readable "Required command method"
          human_readable "intentionally repeated"

          def test_meth; end;
        end

        InvalidCommandMethodRepeatable
      end

      it do
        expect { subject }.to raise_error(ThorEnhance::ValidationFailed, /Please remove the secondary invocation/)
      end

      context "when enhance flag not set" do
        let(:klass) do
          class CommandMethodRepeatable < Thor
            desc "test_meth", "short description"
            human_readable "Required command method"
            human_readable "intentionally repeated"

            def test_meth; end;
          end

          CommandMethodRepeatable
        end

        it do
          expect { subject }.to_not raise_error
        end
      end
    end
  end

  describe "command_method integration" do
    let(:command) { ThorEnhance::Tree.tree(base: MyTestClass)["test_meth"].command }

    it "adds method" do
      expect(command.human_readable[:input]).to eq("Thor Test command")
      expect(command.example).to be_a(Array)
      expect(command.example[0][:input]).to eq("test_meth")
      expect(command.example[1][:input]).to eq("test_meth --test_meth_option")
    end
  end

  describe "method hooks" do
    before do
      allow(instance).to receive(:instance_variable_get).with(:@_initializer).and_return([nil, ["--#{option}"]])
      allow(instance).to receive(:options).and_return(raw)
    end
    let(:raw) { { option => true } }
    let(:instance) { MyTestClass.new(["--#{option}"]) }
    let(:option) { "option1" }
    let(:command) { ThorEnhance::Tree.tree(base: MyTestClass)["test_meth"].command }

    context "with deprecate" do
      context "with String" do
        let(:option) { "option1" }

        it do
          expect { command.run(instance) }.to raise_error(ThorEnhance::OptionDeprecated, /Passing value for option/)
        end
      end

      context "with Hash" do
        context "when warn" do
          let(:option) { "option2" }
          it do
            expect(Kernel).to receive(:warn).with(/WARNING: Provided/)

            command.run(instance)
          end
        end

        context "when raise" do
          let(:option) { "option3" }

          it do
            expect { command.run(instance) }.to raise_error(ThorEnhance::OptionDeprecated, /Passing value for option/)
          end
        end

        context "when incorrect keys" do
          let(:option) { "option5" }

          it do
            expect { command.run(instance) }.to raise_error(ThorEnhance::OptionDeprecated, /Passing value for option/)
          end
        end
      end
    end

    context "with hook" do
      let(:option) { "option4" }
      it do
        expect(Kernel).to receive(:puts).with(/This is the correct option to use/)

        command.run(instance)
      end
    end
  end
end
