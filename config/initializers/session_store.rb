# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cothinkit_session',
  :secret      => 'afbbede002930ecb408e650addcbeda3f7e5c695a6647d20947b4197bbe8e821447c7b49ce15c6d32eca12c5ab70276cc0828cf1a4d9dd1e21f3f9dab0d8f8dd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
