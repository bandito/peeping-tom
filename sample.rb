require 'peep'

puts  Peep.queue_url({:url => "http://www.google.com", :callback => "http://localhost:4567/"})
