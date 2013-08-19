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
      else
        raise ArgumentError, "model must be specified"
      end

      if block_given?
        apply = block
      else
        raise ArgumentError, "block must be specified"
      end

      if opts.include? :scope
        scope = opts[:scope]
      else
        scope = ->(ids) do
          model.where(:id => ids)
        end
      end

      if opts.include? :if
        condition = opts[:if]
      else
        condition = ->() { true }
      end

      @batch_actions[keyword] = condition

      raise ArgumentError, "unexpected number of arguments for scope" if scope.arity < 1 || scope.arity > 2

      define_method(:"batch_#{keyword}") do
        result = instance_exec(&condition)

        raise ActionController::RoutingError.new('batch action is not allowed') unless result

        case scope.arity
        when 1
          objects = instance_exec(params[:ids], &scope)

        when 2
          objects = instance_exec(params[:ids], model.where(:id => params[:ids]), &scope)
          
        end

        instance_exec(objects, &apply)
      end
    end
  end
end
