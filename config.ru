# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# Setup middleware 
#
require 'http_accept_language'
use HttpAcceptLanguage::Middleware

run Rails.application
