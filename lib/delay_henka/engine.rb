module DelayHenka
  class Engine < ::Rails::Engine
    isolate_namespace DelayHenka

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
