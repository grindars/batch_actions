# BatchActions

This gem adds generic support for batch actions to Rails controllers and
InheritedResources.

[![Travis CI](https://secure.travis-ci.org/grindars/batch_actions.png)](https://travis-ci.org/grindars/batch_actions)
[![Code Climate](https://codeclimate.com/github/grindars/batch_actions.png)](https://codeclimate.com/github/grindars/batch_actions)

Sponsored by [Evil Martians](http://evilmartians.com/).

## Installation

Add this line to your application's Gemfile:

    gem 'batch_actions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install batch_actions

## Usage

```ruby
class PostController < ApplicationController
  include BatchActions

  batch_actions do
    model Post

    # Produces #batch_publish action. Requires params[:ids] to get affected
    # instances and call #publish on them.
    batch_action :publish

    # params[:batch_destroy] should be an array containing affected ids
    batch_action :destroy, param_name: :batch_destroy

    # Produced controller action will be called #mass_unpublish (instead of
    # batch_unpublish by default). Method #draft! will be called for each
    # affected instance.
    batch_action :unpublish, action_name: :mass_unpublish, batch_method: :draft!

    # Affected objects will be got inside #destroyed scope, redirection will
    # be done to params[:return_to] instead of url_for(action: :index)
    batch_action :restore,
      scope: ->(model, ids) { Post.destroyed.where(id: ids) },
      respose: -> {
        respond_to do |format|
          format.html { redirect_to params[:return_to] }
        end
      }

    # Produces action #do_batch with dispatches request to concrete
    # actions. Concrete action is determined by param named as action name
    # ("destroy=true" for batch_action :destroy) or by :trigger option value
    # ("call_destroy=true for batch_action :destroy, trigger: :call_destroy).
    dispatch_action(:do_batch)
  end
end
```

## Inheritance

Batch action options and batch actions could be inherited.

```
class Admin::BaseController < ApplicationController
  include BatchActions
  batch_actions do
    param_name :ids_eq
  end
end

class Admin::NewsController < Admin::BaseController
  # You can omit #batch_actions call if you do not want to set options.
  batch_action :destroy
  batch_action :publish
end
```

`#batch_destroy` and `#batch_publish` will require `params[:ids_eq]` to work.

## CanCan

Because of every batch_action creates action called `batch_#{name}`, you can
control access rights with CanCan. Action name could be overriden with
`:action_name` param.

## InheritedResources

Note that you can omit `model` call if you use the [inherited_resources](https://github.com/josevalim/inherited_resources) gem. It grabs scope from `end_of_association_chain`.

## TODO

1. call before and after filters for producted actions if they are called from
   dispatcher.
1. implement flash messages with inherited_resources responders for example.
2. autoinclude it to actioncontroller inside railtie.
3. :tirgger param must be a proc.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
