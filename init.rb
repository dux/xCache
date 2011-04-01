require 'cache_extended'

ActionController::Base.send :before_filter, :set_no_cache_variable


