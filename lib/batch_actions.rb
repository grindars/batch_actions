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

  def batch_action
    action = params[:name]

    raise "action is not allowed" unless batch_actions.include? action.to_sym

    send(:"batch_#{action}")
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
