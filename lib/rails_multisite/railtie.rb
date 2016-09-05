module RailsMultisite
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f }
    end

    initializer "RailsMultisite.init" do |app|
      Rails.configuration.multisite = false
      if File.exists?(ConnectionManagement.config_filename)
        Rails.configuration.multisite = true
        Rails.logger.formatter = RailsMultisite::Formatter.new
        ConnectionManagement.load_settings!
        app.middleware.insert_after(ActiveRecord::ConnectionAdapters::ConnectionManagement, RailsMultisite::ConnectionManagement)
        app.middleware.delete(ActiveRecord::ConnectionAdapters::ConnectionManagement)
        if ENV['RAILS_DB']
          ConnectionManagement.establish_connection(db: ENV['RAILS_DB'].to_sym)
        end
      end
    end
  end
end

