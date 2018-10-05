require_relative './requires'
Faraday.get('http://ukrojob.herokuapp.com')
logger.noise "Finished."