require "batch_actions/version"
require "batch_actions/class_methods"

module BatchActions
  def batch_actions
    return [] unless self.class.class_variable_defined? :@@batch_actions

    actions = self.class.class_variable_get :@@batch_actions
    allowed = []

    actions.each do |keyword, condition|
      if instance_exec(&condition)
        allowed << keyword
      end
    end

    allowed
  end

  def self.included(base)
    base.extend ClassMethods

    if defined?(InheritedResources::Base) &&
       base.kind_of?(InheritedResources::Base)
      batch_model resource_class
    end
  end
end
