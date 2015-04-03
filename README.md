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

Once the gem is installed in your Rails application, you can run the following command to set up an experiment:

    $ bundle exec rake abtest:add_experiment[experiment_name]

To delete an experiment, run the following command:

    $ bundle exec rake abtest:delete_experiment[experiment_name]

To remove all experiments, run the following command:

    $ bundle exec rake abtest:delete_experiments

Those commands will place a stub configuration with instructions in:

    config/initializers/abtest/<experiment_name>.rb

Once you've generated an experiment and configured when it should take effect, you can place your experiment files to overlay on rails in:

    abtest/experiments/<experiment_name>/

So for example:

    abtest/experiments/my_cool_experiment/views/some_controller/foo.html.erb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
