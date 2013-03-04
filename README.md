# BatchActions

This gem adds generic support for batch actions to Rails controllers.

Development sponsored by Evil Martians.

## Installation

Add this line to your application's Gemfile:

    gem 'batch_actions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install batch_actions

## Usage

* Include BatchActions into controller.
* Specify model using batch_model.
* Specify actions using batch_action.

For InheritedResources::Base-derived controllers, resource_class is used as model by default.

### Action definition
    def batch_action(keyword, opts = {}, &block)
    
Supported options:
* model: use specified model instead of controller-wide default
* scope: use specified scope instead of default ->(model) { model.where(:id => params[:ids]) }
* if: allow to execute action only if specified proc returns true, raise exception otherwise.

If block is not specified, default action is used: send keyword to each object in scope.

Set of allowed actions can be queried by calling batch_actions on controller instance.

## Example
    class PostController < ApplicationController
      batch_model Post
      batch_action :destroy, if: ->() { can? :destroy, Post } do |objects|
        objects.each { |o| o.mark_as_deleted! }
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
