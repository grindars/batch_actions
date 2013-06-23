require "batch_actions/version"
require "batch_actions/class_methods"
require "batch_actions/context"

module BatchActions
  def batch_actions
    self.class.batch_actions.batch_actions
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
