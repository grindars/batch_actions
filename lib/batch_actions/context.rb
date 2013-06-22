module BatchActions
  module Context
    def initialize
      @model      = nil
      @scope      = default_scope
      @respond_to = default_response
      @param_name = :ids
    end

    def configure(controller, &block)
      @controller = controller
      instance_exec(&block)
    end

    def model(model)
      @model = model
    end

    def param_name(name)
      @param_name = name
    end

    def scope(&block)
      block_given? or raise ArgumentError, 'Need a block for batch_actions#scope'
      @scope = block
    end

    def respond_to(&block)
      block_given? or raise ArgumentError, 'Need a block for batch_actions#respond_to'
      @respond_to = block
    end

    def batch_action(name, options = {}, &block)
      scope        = options[:scope]        || @scope
      response     = options[:respond_to]   || @respond_to
      param_name   = options[:param_name]   || @param_name
      action_name  = options[:action_name]  || :"batch_#{name}"
      batch_method = options[:batch_method] || options[:action_name] || name

      do_batch_stuff = block || ->() do
        objects.map do |object|
          object.send(batch_method)
        end
      end

      @controller.class_eval do
        define_method action_name do
          @ids     = params[param_name]
          @objects = instance_exec(model, ids, &scope)
          @results = &do_batch_stuff.call(@objects)

          instance_exec(&response)
        end
      end
    end

    def dispatch_action(name)

    end

    private
    def default_scope
      ->(model, ids) do
        tail = if respond_to?(:end_of_association_chain)
          end_of_association_chain
        else
          model or raise 'You must specify batch_actions#model to apply batch action on'
          model
        end
        tail.where(id: ids)
      end
    end

    def default_response
      ->() do
        respond_with(@objects)
      end
    end
  end
end