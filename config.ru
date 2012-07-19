# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'rack'
require 'rack/lobster'

use Rack::Pjax

use Rack::ShowExceptions
use Rack::CommonLogger
use Rack::ShowStatus
use Rack::ContentLength

run Paykido::Application
