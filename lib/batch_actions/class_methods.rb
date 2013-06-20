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
      elsif respond_to?(:resource_class)
        model = resource_class
      else
        raise ArgumentError, "model must be specified"
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
          model.where(:id => params[:ids])
        end
      end

      if opts.include? :if
        condition = opts[:if]
      else
        condition = ->() do
          if self.respond_to? :can?
            can? keyword, model
          else
            true
          end
        end
      end

      @batch_actions[keyword] = condition

      define_method(:"batch_#{keyword}") do
        result = instance_exec(&condition)

        raise "action is not allowed" unless result

        objects = instance_exec(model, &scope)
        apply.call(objects)
      end
    end
  end
end
