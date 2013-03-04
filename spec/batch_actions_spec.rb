require 'spec_helper'

describe BatchActions do
  it "generates batch actions" do
    ctrl = mock_controller(
      :ids => [ 1, 2 ]
    ) do
      batch_model TestModel
      batch_action :test1
    end

    times = 0

    TestModel.should_receive(:where).with({ :id => [ 1, 2 ]}).and_call_original
    TestModel.any_instance.stub(:test1) { times += 1 }

    ctrl.batch_test1

    times.should == 2
  end

  it "requires a model to be specified" do
    expect do
      mock_controller do
        batch_action :test1
      end
    end.to raise_error(ArgumentError)
  end

  it "allows per-action override of a model" do
    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action :test1
      batch_action :test2, :model => TestModel2
    end

    TestModel.should_receive(:where).with({ :id => [ 1 ]}).and_call_original
    TestModel2.should_receive(:where).with({ :id => [ 1 ]}).and_call_original

    TestModel.any_instance.should_receive(:test1).and_return(nil)
    TestModel2.any_instance.should_receive(:test2).and_return(nil)

    ctrl.batch_test1
    ctrl.batch_test2
  end

  it "allows to specify scope" do
    scope_called = false

    instance = TestModel.new
    instance.should_receive(:test1).and_return(nil)

    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action :test1, :scope => ->(model) do
        scope_called = true

        [ instance ]
      end
    end

    ctrl.batch_test1

    scope_called.should be_true
  end

  it "allows to override default apply" do
    block_called = nil

    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action(:test1) do |objects|
        block_called = objects
      end
    end

    ctrl.batch_test1

    block_called.should_not be_nil
    block_called.length.should == 1
  end

  it "supports :if" do
    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action :test, :if => ->() { false }
    end

    expect { ctrl.batch_test1 }.to raise_error
    ctrl.batch_actions.should be_empty
  end

  it "implements batch_actions" do
    ctrl = mock_controller do
      batch_model TestModel

      batch_action :test1
      batch_action :test2
      batch_action :test3, :if => ->() { false }
    end

    ctrl.batch_actions.should == [ :test1, :test2 ]
  end

  it "supports InheritedResources" do
    expect do
      mock_controller(:parent => InheritedResources::Base) do
        batch_action :test1
      end
    end.to_not raise_error
  end

  it "implements batch_action" do
    [ "test1", "test2" ].each do |action|
      ctrl = mock_controller(
        :ids => [ 1 ],
        :name => action
      ) do
        batch_model TestModel
        batch_action :test1
        batch_action :test2
      end

      TestModel.any_instance.should_receive(action.to_sym).and_return(nil)
      ctrl.batch_action
    end
  end
end
