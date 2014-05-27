# Abtest

A-B testing framework and manager for Rails.  This gem allows the addition of experiments that change view code and assets
based on the results of a simple test proc.

This gem modifies ActionView::Base as well as the global assets environment to enable overrides in the experiments directory to 
take effect.

## Installation

Add this line to your application's Gemfile:

    gem 'abtest'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install abtest

## Usage

Once the gem is installed in your Rails application, rou can run the following command to set up an experiment:

    $ bundle exec rake abtest:add_experiment[experiment_name]

To remove all experiments, run the following command:

    $ bundle exec rake abtest:delete_experiments

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
