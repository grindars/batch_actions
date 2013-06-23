module BatchActions
  module ClassMethods
    def batch_actions(&block)
      @batch_actions ||= BatchActions::Context.new
      @batch_actions.configure(self, &block) if block_given?
      @batch_actions
    end
  end
end
