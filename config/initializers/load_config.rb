require "#{RAILS_ROOT}/lib/ruby_classes_extensions"


#require "#{RAILS_ROOT}/lib/xmpp_message_extension"
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV].recursive_symbolize_keys!
S3_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/amazon_s3.yml")[RAILS_ENV].recursive_symbolize_keys!
PAYPAL_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/paypal.yml")[RAILS_ENV].recursive_symbolize_keys!
SOCKY_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/socky_server.yml")[RAILS_ENV].recursive_symbolize_keys!