# frozen_string_literal: true

RSpec.describe ThorEnhance do
  describe "option" do
    context "with missing required option" do
      let(:option) { ::Thor::Option.new("option", revoke: false) }

      it do
        expect { option }.to raise_error(ThorEnhance::RequiredOption, /does not have required option/)
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

  describe "command_method integration" do
    let(:command) { ThorEnhance::Tree.tree(base: MyTestClass)["test_meth"].command }

    it "adds method" do
      expect(command.human_readable).to eq("Thor Test command")
      expect(command.example).to be_a(Array)
      expect(command.example[0]).to eq("bin/thor test_meth")
      expect(command.example[1]).to eq("bin/thor test_meth --test_meth_option")
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
