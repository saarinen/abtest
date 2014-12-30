namespace :abtest do
  desc "Create a new experiment scaffold. Experiment name is a required arg. (rake abtest:add_experiment[name])"
  task :add_experiment, [:name] => :environment do |t, args|
    name = args[:name]

    if (name.nil? || name.blank?)
      puts "Experiment name is required.  Usage: rake abtest:add_experiment[name]"
      next
    end

    # Add directories for views and assets
    app_config            = Rails.application.config
    test_root             = File.join(Rails.root, 'abtest')
    experiment_path       = File.join(test_root, 'experiments', name)
    application_css_path  = File.join(experiment_path, app_config.assets.prefix, 'stylesheets')
    images_path           = File.join(experiment_path, app_config.assets.prefix, 'images')
    javascript_path       = File.join(experiment_path, app_config.assets.prefix, 'javascripts')
    view_path             = File.join(experiment_path, 'views')
    experiment_init_path  = File.join(Rails.root, 'config', 'initializers', 'abtest')

    FileUtils.mkdir_p(view_path)
    FileUtils.mkdir_p(application_css_path)
    FileUtils.mkdir_p(images_path)
    FileUtils.mkdir_p(javascript_path)
    FileUtils.mkdir_p(experiment_init_path)

    # Create a new initializer file if it doesn't exist already
    initializer_path = File.join(Rails.root, 'config', 'initializers', 'abtest.rb')
    unless File.exists?(initializer_path)
      ab_template = File.read(File.join(File.dirname(__FILE__), 'templates', 'abtest.erb'))
      renderer    = ERB.new(ab_template)
      result      = renderer.result(binding)
      File.open(initializer_path, 'w') {|f| f.write(result) }
    end

    # Add template initializer
    template = File.read(File.join(File.dirname(__FILE__), 'templates', 'initializer.erb'))
    renderer = ERB.new(template)
    result = renderer.result(binding)

    # Create new initializer file
    init_file_path = File.join(experiment_init_path, "#{name}.rb")
    File.open(init_file_path, 'a') { |f| f.write(result) }

    puts "Please edit #{init_file_path} to configure experiment."
  end

  desc "Delete all experiments"
  task :delete_experiments => :environment do
    # Remove experiments directory
    FileUtils.rm_rf(File.join(Rails.root, 'abtest'))
    FileUtils.rm_rf(File.join(Rails.root, 'config', 'initializers', 'abtest'))

    # Remove initializer
    FileUtils.rm_f(File.join(Rails.root, 'config', 'initializers', 'abtest.rb'))

    puts "All tests removed"
  end

  desc "Delete experiment. Experiment name is a required arg. (rake abtest:delete_experiment[name])"
  task :delete_experiment, [:name] => :environment do |t, args|
    name = args[:name]

    if (name.nil? || name.blank?)
      puts "Experiment name is required.  Usage: rake abtest:add_experiment[name]"
      next
    end

    test_root             = File.join(Rails.root, 'abtest')
    experiment_path       = File.join(test_root, 'experiments', name)
    experiment_init_path  = File.join(Rails.root, 'config', 'initializers', 'abtest')
    init_file_path        = File.join(experiment_init_path, "#{name}.rb")

    # Remove experiments directory
    FileUtils.rm_rf(experiment_path)

    # Remove initializer
    FileUtils.rm_f(init_file_path)

    puts "Experiment #{name} removed."
  end

end