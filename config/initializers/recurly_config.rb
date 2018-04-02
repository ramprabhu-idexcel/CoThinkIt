require 'recurly' 

# /config/initializers/recurly_config.rb
Recurly.configure do |c|
  c.username = 'payments@cothinkit.com'
  c.password = 'railsfactory1'
  c.site = 'https://cothinkit.recurly.com'
end
