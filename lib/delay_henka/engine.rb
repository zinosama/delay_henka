module DelayHenka
  class Engine < ::Rails::Engine
    isolate_namespace DelayHenka

    # load service directory
    Dir[File.expand_path('../../../app/services/delay_henka/*.rb', __FILE__)].each { |f| require f }

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
