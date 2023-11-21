# frozen_string_literal: true

RSpec.describe ThorEnhance::Tree do
  before { described_class.reset_ignore_commands! }

  describe ".add_ignore_commands" do
    subject { described_class.add_ignore_commands(command_name) }

    let(:command_name) { "some_command_name" }
    it { expect { subject }.to change { described_class.ignore_commands.count }.by(1) }

    it do
      subject
      expect(described_class.ignore_commands).to include(command_name)
    end
  end

  describe ".ignore_commands" do
    it do
      expect(described_class.ignore_commands).to eq(described_class::DEFAULT_IGNORE_COMMANDS)
    end
  end

  describe ".reset_ignore_commands!" do
    before { described_class.add_ignore_commands(command_name) }
    let(:command_name) { "some_command_name" }
    it { expect(described_class.reset_ignore_commands!).to_not include(command_name) }
  end

  describe ".tree" do
    context "with children" do
      subject { described_class.tree(base: MyTestClass) }

      it "initializes children" do
        expect(subject.count).to eq(2)
      end

      it "command access methods" do
        subject.each do |name, object|
          expect{ object.command.human_readable }.to_not raise_error
          expect{ object.command.example }.to_not raise_error
        end
      end

      it "option access methods" do
        subject.each do |name, object|
          object.command.options.each do |key, option|
            expect{ option.classify }.to_not raise_error
            expect{ option.revoke }.to_not raise_error
          end
        end
      end
    end

    context "without children" do
      subject { described_class.tree(base: MyTestClass::SubCommand) }

      it "no children" do
        expect(subject.count).to eq(1)
        subject.each { expect(_2.children?).to eq(false) }
      end

      it "command access methods" do
        subject.each do |name, object|
          expect{ object.command.human_readable }.to_not raise_error
          expect{ object.command.example }.to_not raise_error
        end
      end

      it "option access methods" do
        subject.each do |name, object|
          object.command.options.each do |key, option|
            expect{ option.classify }.to_not raise_error
            expect{ option.revoke }.to_not raise_error
          end
        end
      end
    end
  end
end
