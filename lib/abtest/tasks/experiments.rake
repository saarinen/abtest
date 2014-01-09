namespace :abtest do
  desc "Create a new experiment scaffold. Experiment name is a required arg. (rake abtest:add_experiment[name])"
  task :add_experiment, [:name] => :environment do |t, args|
    name = args[:name]
    puts "Experiment name is required" and return if name.nil?

    # Check to see if we have a tests directory
    Dir.mkdir("#{Rails.root}/app/views/tests") unless Dir.exists?("#{Rails.root}/app/views/tests")

    # Create a folder for this experiment
    experiment_path = "#{Rails.root}/app/views/tests/#{args[:name]}"
    Dir.mkdir(experiment_path) unless Dir.exists?(experiment_path)

    # Create a new initializer file if it doesn't exist already
    initializer_path = "#{Rails.root}/config/initializers/abtest.rb"
    FileUtils.touch(initializer_path) unless File.exists?(initializer_path)

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
    # Remove tests directory
    FileUtils.rm_rf("#{Rails.root}/app/views/tests") if Dir.exists?("#{Rails.root}/app/views/tests")

    # Remove initializer
    FileUtils.rm("#{Rails.root}/config/initializers/abtest.rb") if Dir.exists?("#{Rails.root}/config/initializers/abtest.rb")

    puts "All tests removed"
  end
end