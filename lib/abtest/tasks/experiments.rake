namespace :abtest do
  desc "Create a new experiment scaffold. Experiment name is a required arg. (rake abtest:add_experiment[name])"
  task :add_experiment, [:name] => :environment do |t, args|
    name = args[:name]
    puts "Experiment name is required" and return if name.nil?

    # Check to see if we have a experiments directory
    FileUtils.mkdir_p("#{Rails.root}/experiments")

    # Add directories for views and assets
    experiment_path       = "#{Rails.root}/experiments/#{name}"
    application_css_path  = "#{experiment_path}/assets/#{name}/stylesheets"
    image_path            = "#{experiment_path}/assets/#{name}/images"
    view_path             = "#{experiment_path}/views"
    FileUtils.mkdir_p(view_path)
    FileUtils.mkdir_p(application_css_path)
    FileUtils.mkdir_p(image_path)

    # Add template stylesheet
    css_template = File.read("#{File.dirname(__FILE__)}/templates/application.scss.erb")
    renderer = ERB.new(css_template)
    css_result = renderer.result(binding)

    File.open("#{application_css_path}/application.scss", 'w') {|f| f.write(css_result) }

    # Create a new initializer file if it doesn't exist already
    initializer_path = "#{Rails.root}/config/initializers/abtest.rb"
    unless File.exists?(initializer_path)
      initializer_template = File.read("#{File.dirname(__FILE__)}/templates/precompile_config.erb")
      renderer = ERB.new(initializer_template)
      result = renderer.result(binding)

      File.open(initializer_path, 'a') { |f| f.write(result) }
    end

    # Add template initializer
    template = File.read("#{File.dirname(__FILE__)}/templates/initializer.erb")
    renderer = ERB.new(template)
    result = renderer.result(binding)

    # Append initializer code to end of file
    File.open(initializer_path, 'a') { |f| f.write(result) }

    puts "Please edit #{initializer_path} to configure experiment."
  end

  desc "Precompile assets for a specific experiment"
  task :assets_precompile, [:name] => :environment do |t, args| 
    name = args[:name]
    puts "Experiment name is required" and return if name.nil?

    experiment_path       = "#{Rails.root}/experiments/#{name}"
    application_css_path  = "#{experiment_path}/assets/#{name}/stylesheets"

    Rails.application.config.assets.paths = ["#{experiment_path}/assets/"] + Rails.application.config.assets.paths
    Rails.application.config.assets.precompile += ["#{application_css_path}/application.scss"]
    
    Rake::Task['assets:precompile'].invoke
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