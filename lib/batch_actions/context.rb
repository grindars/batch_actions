module BatchActions
  class Context
    attr_reader :batch_actions

    def initialize
      @model      = nil
      @scope      = default_scope
      @respond_to = default_response
      @param_name = :ids

      @batch_actions = {}
    end

    def configure(controller, &block)
      @controller = controller
      instance_exec(&block)
    end

    private
    def param_name(name)
      @param_name = name
    end

    def model(resource_class)
      @model = resource_class
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
      trigger      = options[:trigger]      || name
      model        = options[:model]        || @model

      do_batch_stuff = block || ->(objects) do
        results = objects.map do |object|
          [object, object.send(batch_method)]
        end
        Hash[results]
      end

      @controller.class_eval do
        define_method action_name do
          @ids     = params[param_name]
          @objects = instance_exec(model, @ids, &scope)
          @results = do_batch_stuff.call(@objects)

          instance_exec(&response)
        end
      end

      @batch_actions[action_name] = trigger
    end

    def dispatch_action(name = 'batch_action')
      @controller.class_eval do
        define_method name do
          batch_actions.detect do |action, trigger|
            if params.key?(trigger)
              send(action)
            end
          end
        end
      end
    end

    def default_scope
      ->(model, ids) do
        tail = if respond_to?(:resource_class) && model.nil?
          end_of_association_chain
        else
          model
        end
        tail or raise ArgumentError, 'You must specify batch_actions#model to apply batch action on'
        tail.where(id: ids)
      end
    end

    def default_response
      ->() do
        respond_with(@objects, location: url_for(action: :index))
      end
    end
  end
end