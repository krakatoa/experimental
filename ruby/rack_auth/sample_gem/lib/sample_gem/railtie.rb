module SampleGem
  class Railtie < Rails::Railtie
    initializer "sample_gem.insert_middleware" do |app|
      app.config.middleware.use "SampleGem::RsaAuth"
    end
  end
end

# then, in the main lib:
# require "tbbc/railtie" if defined? Rails
