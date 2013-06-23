require 'simplecov'

SimpleCov.start
require 'batch_actions'

class TestModel
  def self.where(query)
    query[query.keys.first].map { self.new }
  end
end

class TestModel2
  def self.somewhere(query)
    query[query.keys.first].map { self.new }
  end
end

def mock_controller(params = {}, &block)
  parent = params.delete(:parent) || Object

  mock_class = Class.new(parent) do
    include BatchActions

    def params
      self.class.instance_variable_get :@params
    end

    def respond_with(object, *args)
      "Default response"
    end

    def url_for(*args)
      ""
    end
  end

  mock_class.class_exec(&block)
  mock_class.instance_variable_set :@params, params

  mock_class.new
end

RSpec.configure do |config|
  config.mock_with :rr
end