require 'spec_helper'

describe BatchActions do
  it 'generates batch actions' do
    params = {:ids => [ 1, 2 ]}

    ctrl = mock_controller(params) do
      batch_actions do
        model TestModel
        batch_action :test1
      end
    end

    mock.proxy(TestModel).where(id: params[:ids]).once
    any_instance_of(TestModel) do |klass|
      mock(klass).test1.times(params[:ids].length)
    end

    ctrl.batch_test1.should == 'Default response'
  end

  it 'requires a model to be specified' do
    ctrl = mock_controller do
      batch_actions do
        batch_action :test1
      end
    end

    -> { ctrl.batch_test1 }.should raise_error(ArgumentError)
  end

  it 'does not require to specify model for inherited_resources' do
    ctrl = mock_controller do
      def self.resource_class
        TestModel
      end

      def end_of_association_chain
        resource_class
      end

      batch_actions do
        batch_action :test1
      end
    end
    -> { ctrl.batch_test1 }.should_not raise_error(ArgumentError)
  end

  it 'allows per-action override of params' do
    ctrl = mock_controller(
      :ids_eq => [1, 2],
      :the_ids => [1, 2]
    ) do
      batch_actions do
        model TestModel

        param_name :the_ids
        scope { |model, ids| model.where(other_id: ids) }
        respond_to { 'Correct response' }

        batch_action :test1
        batch_action :test2,
          param_name: :ids_eq,
          model: TestModel2,
          action_name: 'test_action',
          batch_method: 'test_method',
          scope: ->(model, ids) { model.somewhere(id: ids) },
          respond_to: -> { 'Test response overriden' }
      end
    end

    mock.proxy(TestModel).where(other_id: [1, 2]).once
    any_instance_of(TestModel) do |klass|
      mock(klass).test1.twice
    end

    mock.proxy(TestModel2).somewhere(id: [1, 2]).once
    any_instance_of(TestModel2) do |klass|
      mock(klass).test_method.twice
    end

    ctrl.batch_test1.should == 'Correct response'
    ctrl.test_action.should == 'Test response overriden'
  end

  it 'implements #batch_actions' do
    ctrl = mock_controller do
      batch_actions do
        batch_action :test1
        batch_action :test2
        batch_action :test3
      end
    end

    ctrl.batch_actions.should == {
      batch_test1: :test1,
      batch_test2: :test2,
      batch_test3: :test3
    }
  end

  it 'implements dispatch action' do
    ctrl = mock_controller(:test1 => true, ids: [1, 2]) do
      batch_actions do
        model TestModel
        dispatch_action
        batch_action :test1
      end
    end

    any_instance_of(TestModel) do |klass|
      mock(klass).test1.any_times
    end
    proxy(ctrl).batch_test1.once

    ctrl.batch_action
  end
end
