require "batch_actions/version"
require "batch_actions/class_methods"

module BatchActions
  def batch_actions
    return [] unless self.class.instance_variable_defined? :@batch_actions

    actions = self.class.instance_variable_get :@batch_actions
    allowed = []

    actions.each do |keyword, condition|
      if condition.nil? || instance_exec(&condition)
        allowed << keyword
      end
    end

    allowed
  end

  def batch_action
    batch_action_button = (batch_actions & params.keys.map(&:to_sym)).first
    action = params[:name] || batch_action_button

    (not(action.nil?) && batch_actions.include?(action.to_sym)) or
      raise "batch action #{action} is not defined"

    send(:"batch_#{action}")
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
