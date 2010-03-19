require 'socket'

def socket_open number
 begin
   TCPSocket.new('localhost', number).close
 rescue Exception
   end
end

Given /^I startup a remote instance$/ do
  @thread = Thread.new { system("jruby bin/redcar --port=6789") }
  while(!socket_open(6789))
    print '.'; STDOUT.flush
    sleep 0.1
  end
  puts 'started remote!'
end

When /^I open "([^\"]*)" from the command line$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end


