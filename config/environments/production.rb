# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.session = {:domain => '.cothinkit.com'}


config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

#ActionController::Base.asset_host = "https://assets%d.cothinkit.com"
ActionController::Base.asset_host = "https://cti-asset%d.s3.amazonaws.com"

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"
#~ ActionController::Base.asset_host = Proc.new { |source, request|
    #~ # the following will route to Amazon S3 + CloudFront if /images asset (setup with CNAMEs as domains cdn0-cdn3)
    #~ #   and will route to cdn for anything else (js, css, html), which routes to RMSR's own server so that files can be gzipped and served
    #~ if source.starts_with?('/images')
      #~ unless request.ssl? # CloudFront does not support HTTPS, but S3 does
        #~ "http://cdn#{source.hash % 4}.yourapp.com"
      #~ else # For SSL we want the certificate to match the hosting domain for cloudfront
        #~ [ "https://yourcloudfrontdist0.cloudfront.net",
          #~ "https://yourcloudfrontdist1.cloudfront.net",
          #~ "https://yourcloudfrontdist2.cloudfront.net",
          #~ "https://yourcloudfrontdist3.cloudfront.net" ][source.hash % 4]
      #~ end
    #~ else
      #~ # use the cahed and zipped subdomain for assets that can be zipped (i.e. non-binary filetypes)
      #~ # => text/html text/css application/x-javascript application/javascript
      #~ "#{request.protocol}cache.yourapp.com"
    #~ end
  #~ }