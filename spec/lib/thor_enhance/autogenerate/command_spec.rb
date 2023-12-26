# frozen_string_literal: true

RSpec.describe ThorEnhance::Autogenerate::Command do
  let(:instance) { described_class.new(**params) }
  let(:tree) { ThorEnhance::Tree.tree(base: MyTestClass) }
  let(:sampled_command) do
    tree.select do |name, child|
      !child.children?
    end.to_a.sample[1]
  end

  let(:sampled_subcommand) do
    tree.select do |name, child|
      child.children?
    end.to_a.sample[1]
  end

  let(:params) do
    {
      leaf: leaf,
      name: name,
      basename: basename,
      parent: nil,
      root: "",
    }
  end
  let(:name) { leaf.command.name }
  let(:basename) { "thor_enhance_basename" }

  describe ".command_erb" do
    subject { instance.command_erb }

    context "with children" do
      let(:leaf) { sampled_subcommand }

      it do
        expect { subject }.to_not raise_error
      end
    end

    context "without children" do
      let(:leaf) { sampled_command }

      it do
        expect { subject }.to_not raise_error
      end
    end
  end
end
