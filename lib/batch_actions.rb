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
    action = params[:name] || (batch_actions & params.keys.map(&:to_sym)).first

    batch_actions.include?(action.try(:to_sym)) or raise "action is not allowed"

    send(:"batch_#{action}")
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
