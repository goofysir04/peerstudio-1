Airbrake.configure do |config|
  config.api_key = '13ade881ab0e9963df22556dbeaf5199'
  config.host    = 'discourseerrors.herokuapp.com'
  config.port    = 80
  config.secure  = config.port == 443
end
