require 'simplecov'
SimpleCov.start

require 'batch_actions'

class TestModel
  def self.where(query)
    query[:id].map { self.new }
  end
end

class TestModel2
  def self.where(query)
    query[:id].map { self.new }
  end
end

module InheritedResources
  class Base
    def self.resource_class
      TestModel
    end
  end
end

def mock_controller(params = {}, &block)
  parent = params.delete(:parent) || Object

  mock_class = Class.new(parent) do
    include BatchActions

    def params
      self.class.instance_variable_get :@params
    end
  end

  mock_class.class_exec(&block)
  mock_class.instance_variable_set :@params, params

  mock_class.new
end
