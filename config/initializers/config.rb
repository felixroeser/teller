require 'yaml'

CONFIG = YAML.load_file("#{Rails.root}/config/config.yml").with_indifferent_access[Rails.env]