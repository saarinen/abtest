namespace :abtest do
  desc "Create a new experiment scaffold. Experiment name is a required arg. (rake abtest:add_experiment[name])"
  task :add_experiment, [:name] => :environment do |t, args|
    name = args[:name]
    puts "Experiment name is required" and return if name.nil?

    # Check to see if we have a experiments directory
    FileUtils.mkdir_p("#{Rails.root}/experiments")

    # Add directories for views and assets
    app_config            = Rails.application.config
    test_root             = File.join(Rails.root, 'abtest')
    experiment_path       = File.join(test_root, 'experiments', name)
    application_css_path  = File.join(experiment_path, app_config.assets.prefix, 'stylesheets')
    images_path           = File.join(experiment_path, app_config.assets.prefix, 'images')
    javascript_path       = File.join(experiment_path, app_config.assets.prefix, 'javascript')
    view_path             = File.join(experiment_path, 'views')

    FileUtils.mkdir_p(view_path)
    FileUtils.mkdir_p(application_css_path)
    FileUtils.mkdir_p(images_path)
    FileUtils.mkdir_p(javascript_path)

    # Create a new initializer file if it doesn't exist already
    initializer_path = "#{Rails.root}/config/initializers/abtest.rb"
    unless File.exists?(initializer_path)
      ab_template = File.read("#{File.dirname(__FILE__)}/templates/abtest.erb")
      renderer    = ERB.new(ab_template)
      result      = renderer.result(binding)
      File.open(initializer_path, 'w') {|f| f.write(result) }
    end

    # Add template initializer
    template = File.read("#{File.dirname(__FILE__)}/templates/initializer.erb")
    renderer = ERB.new(template)
    result = renderer.result(binding)

    # Append initializer code to end of file
    File.open(initializer_path, 'a') { |f| f.write(result) }

    puts "Please edit #{initializer_path} to configure experiment."
  end

  desc "Delete all experiments"
  task :delete_experiments => :environment do
    # Remove experiments directory
    FileUtils.rm_rf("#{Rails.root}/experiments")

    # Remove initializer
    FileUtils.rm_f("#{Rails.root}/config/initializers/abtest.rb")

    puts "All tests removed"
  end
end