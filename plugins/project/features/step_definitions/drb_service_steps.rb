require 'socket'
require 'drb'

def socket_open number
 begin
   TCPSocket.new('localhost', number).close
 rescue Exception
   return false
 end
 true
end


Given /^I shutdown a remote instance$/ do
  puts 'shutting it down'
  DRbObject.new(nil, "druby://127.0.0.1:6789").shutdown
  puts 'joining'
  @thread.join
end


Given /^I startup a remote instance$/ do
  @thread = Thread.new { system("jruby bin/redcar --port=6789") }
  while(!socket_open(6789))
    print 'w'; STDOUT.flush
    sleep 0.1
  end
  puts 'started remote!'
end

When /^I open "([^\"]*)" from the command line$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should not remotely see "([^\"]*)" in the edit tab$/ do |arg1|
  get_stats
  require 'ruby-debug'
  debugger
  pending # express the regexp above with the code you wish you had
end

def get_stats
  a = DRbObject.new("druby://localhost:6789").examine_internals_drb
  puts a
  a  
end

Then /^I should remotely see "([^\"]*)" in the edit tab$/ do |arg1|
  pending
end

