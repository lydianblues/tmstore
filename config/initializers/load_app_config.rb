raw_config = File.read(Rails.root.to_s + "/config/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys
