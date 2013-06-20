module BatchActions
  module ClassMethods
    def batch_model(klass)
      @batch_model = klass
    end

    def batch_action(keyword, opts = {}, &block)
      @batch_actions = {} if @batch_actions.nil?

      if opts.include? :model
        model = opts[:model]
      elsif !@batch_model.nil?
        model = @batch_model
      elsif not(respond_to?(:resource_class))
        raise ArgumentError, 'model must be specified'
      end

      if block_given?
        apply = block
      else
        apply = ->(objects) do
          objects.each do |object|
            object.send(keyword)
          end
        end
      end

      if opts.include? :scope
        scope = opts[:scope]
      else
        scope = ->(model) do
          tail = if respond_to?(:end_of_association_chain)
            end_of_association_chain
          else
            model
          end
          tail.where(:id => params[:ids])
        end
      end

      condition = opts[:if] if opts[:if]

      @batch_actions[keyword] = condition

      define_method(:"batch_#{keyword}") do
        if condition
          result = instance_exec(&condition)
          raise "action is not allowed" unless result
        end

        objects = instance_exec(model, &scope)
        apply.call(objects)
      end
    end
  end
end
