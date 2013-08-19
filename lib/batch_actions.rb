require "batch_actions/version"
require "batch_actions/class_methods"

module BatchActions
  def batch_actions
    return [] unless self.class.instance_variable_defined? :@batch_actions

    actions = self.class.instance_variable_get :@batch_actions
    allowed = []

    actions.each do |keyword, condition|
      if instance_exec(&condition)
        allowed << keyword
      end
    end

    allowed
  end

  def dispatch_batch
    name = params[:batch_action]

    allowed = batch_actions.detect { |action| action.to_s == name.to_s }
    unless allowed
      raise ActionController::RoutingError.new('batch action is not allowed')
    end

    self.status, headers, self.response_body = self.class.action(:"batch_#{name}").call(env)
    self.headers.merge! headers
  end

  def self.included(base)
    base.extend ClassMethods

    if defined?(InheritedResources::Base) &&
       base < InheritedResources::Base
      base.batch_model base.resource_class
    end
  end
end
