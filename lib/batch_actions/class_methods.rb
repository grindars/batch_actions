module BatchActions
  module ClassMethods
    def batch_model(klass)
      class_variable_set :@@batch_model, klass
    end

    def batch_action(keyword, opts = {}, &block)
      if !class_variable_defined? :@@batch_actions
        class_variable_set :@@batch_actions, {}
      end

      actions = class_variable_get :@@batch_actions

      if opts.include? :model
        model = opts[:model]
      elsif class_variable_defined? :@@batch_model
        model = class_variable_get :@@batch_model
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
        condition = ->() { true }
      end

      actions[keyword] = condition

      define_method(:"batch_#{keyword}") do
        result = instance_exec(&condition)

        raise "action is not allowed" unless result

        objects = instance_exec(model, &scope)
        apply.call(objects)
      end
    end
  end
end
