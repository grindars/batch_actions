# BatchActions

This gem adds generic support for batch actions to Rails controllers.

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

  batch_model Post

  # Runs `model.publish` for every model from params[:ids]
  batch_action :publish

  # Runs `model.destroy` for every model from params[:ids] or throws exception unless you can
  batch_action :destroy, if: ->() { can? :destroy, Post }

  # Runs block for every model from params[:ids]
  batch_action :specific do |objects|
    objects.each{|x| x.specific!}
  end

  # Runs `model.resurrect` for every model from returned relation
  batch_action :resurrect, :scope => ->(ids) { Post.where(other_ids: ids) }
end
```

Note that you can omit `batch_model` call if you use the [inherited_resources](https://github.com/josevalim/inherited_resources) gem. It grabs your model class from `resource_class`.

There's one more important thing to know: set of active batch actions can be retrieved from controller by calling `batch_actions` on controller instance.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
