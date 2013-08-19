require 'spec_helper'

describe BatchActions do
  it "generates batch actions" do
    ctrl = mock_controller(
      :ids => [ 1, 2 ]
    ) do
      batch_model TestModel
      batch_action :test1 do |list|
        list.each &:test1
      end
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
        batch_action :test1 do |list|
          list.each &:test1
        end
      end
    end.to raise_error(ArgumentError)
  end

  it "requires a block to be specified" do
    expect do
      mock_controller do
        batch_model TestModel

        batch_action :test1
      end
    end.to raise_error(ArgumentError)
  end

  it "allows per-action override of a model" do
    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action :test1 do |list|
        list.each &:test1
      end
      batch_action :test2, :model => TestModel2 do |list|
        list.each &:test2
      end
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
    instance.should_receive(:test1).exactly(2).times.and_return(nil)

    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action(:test1, :scope => ->(ids) do
        scope_called = true

        [ instance ]
      end) do |list|
        list.each &:test1
      end

      batch_action(:test2, :scope => ->(ids, scope) do
        scope_called = true

        [ instance ]
      end) do |list|
        list.each &:test1
      end
    end

    ctrl.batch_test1
    scope_called.should be_true

    scope_called = false
    ctrl.batch_test2
    scope_called.should be_true


  end

  it "supports :if" do
    ctrl = mock_controller(
      :ids => [ 1 ]
    ) do
      batch_model TestModel

      batch_action(:test, :if => ->() { false }) do |list|
        list.each &:test
      end
    end

    expect { ctrl.batch_test1 }.to raise_error
    ctrl.batch_actions.should be_empty
  end

  it "implements batch_actions" do
    ctrl = mock_controller do
      batch_model TestModel

      batch_action :test1 do |list|
        list.each &:test1
      end
      batch_action :test2 do |list|
        list.each &:test2
      end
      batch_action(:test3, :if => ->() { false }) do |list|
        list.each &:test3
      end
    end

    ctrl.batch_actions.should == [ :test1, :test2 ]
  end

  it "supports InheritedResources" do
    expect do
      mock_controller(:parent => InheritedResources::Base) do
        batch_action(:test1) do |list|
          list.each &:test1
        end
      end
    end.to_not raise_error
  end

  it "implements dispatch_batch" do
    [ "test1", "test2" ].each do |action|
      ctrl = mock_controller(
        :ids => [ 1 ],
        :batch_action => action
      ) do
        batch_model TestModel
        batch_action :test1 do |list|
          list.each &:test1
        end
        batch_action :test2 do |list|
          list.each &:test2
        end
      end

      TestModel.any_instance.should_receive(action.to_sym).and_return(nil)
      ctrl.dispatch_batch
    end
  end

  it "throws on disallowed action in dispatch_batch" do
    ctrl = mock_controller(
      :batch_action => :test
    ) do
    end

    expect do
      ctrl.dispatch_batch
    end.to raise_error(ActionController::RoutingError)
  end
end
