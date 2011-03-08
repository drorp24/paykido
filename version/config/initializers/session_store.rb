# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_version_session',
  :secret      => '1a71b17ef6e34c56d5790fcf63f334bab41ccace635b2b5ab6d291da5a044bde168da8d84702903545457347e53ae2fb89d085d65ed23fd8eaebb1da1a9ef323'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
