# frozen_string_literal: true

require "thor_enhance/autogenerate"

RSpec.describe Thor do
  # Stub this out because we dont need to test Thor behavior
  before do
    allow(instance).to receive(:options).and_return(raw)
    allow($stderr).to receive(:print)
    allow(ThorEnhance::Autogenerate).to receive(:execute!).and_return(result)
  end
  let(:raw) { OpenStruct.new(subcommand: subcommand, command: input_command, root: nil) }
  let(:subcommand) { nil }
  let(:input_command) { nil }
  let(:instance) { MyTestClass.new }
  let(:command) { MyTestClass.all_commands["thor_enhance_autogenerate"] }
  let(:status) { :pass }
  let(:msg_array) { ["this", "fails", "too", "much"] }
  let(:result) { { status: status, msg_array: msg_array, saved_status: saved_status } }
  let(:saved_status) do
    [
      { path: "some/cool/path", diff: :new, apply: apply },
      { path: "some/different/path", diff: :same, apply: apply },
      { path: "some/perfect/path", diff: :overwite, apply: apply },
      { path: "some/not_perfect/path", diff: :else, apply: apply },
    ]
  end

  let(:apply) { true }
  subject { command.run(instance) }

  context "when fail" do
    let(:status) { :fail }

    it do
      expect($stderr).to receive(:print).exactly(3 + msg_array.count)

      expect { subject }.to raise_error(SystemExit)
    end
  end

  context "when pass" do
    let(:status) { :pass }

    it do
      expect { subject }.to_not raise_error
    end

    context "when not applied" do
      let(:apply) { false }

      it do
        expect { subject }.to_not raise_error
      end
    end

    context "when apply" do
      it do
        expect { subject }.to_not raise_error
      end
    end
  end

  it do
    expect { subject }.to_not raise_error
  end


  it { expect(Thor.instance_methods).to include(:thor_enhance_autogenerate) }
end
