#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__) + "/../lib" if $0 == __FILE__
require 'optparse'
require 'lunchy'

CONFIG = {}
OPERATIONS = %w(start stop restart ls list status install uninstall rm show edit)

option_parser = OptionParser.new do |opts|
  opts.banner = "Lunchy #{Lunchy::VERSION}, the friendly launchctl wrapper\n" \
    "Usage: #{File.basename(__FILE__)} [#{OPERATIONS.join('|')}] [options]"

  opts.on("-x", "--exact", "Force exact (case insensitive) match when specifying a [pattern]") do
    CONFIG[:exact] = true
  end

  opts.on("-F", "--force", "Force start (disabled) agents") do |verbose|
    CONFIG[:force] = true
  end

  opts.on("-v", "--verbose", "Show command executions") do |verbose|
    CONFIG[:verbose] = true
  end

  opts.on("-w", "--write", "Persist command") do |verbose|
    CONFIG[:write] = true
  end

  opts.on("-l", "--long", "Display absolute paths when listing agents") do
    CONFIG[:long] = true
  end

  opts.on("-s", "--symlink", "Use a symlink for installation") do |verbose|
    CONFIG[:symlink] = true
  end

  opts.separator <<-EOS
Supported commands:
 ls [-l] [pattern]       Show the list of installed agents, with optional [pattern] filter
 list [-l] [pattern]     Alias for 'ls'
 start [-wF] [pattern]   Start the first agent matching [pattern]
 stop [-w] [pattern]     Stop the first agent matching [pattern]
 restart [pattern]       Stop and start the first agent matching [pattern]
 status [pattern]        Show the PID and label for all agents, with optional [pattern] filter
 install [-s] [file]     Install [file] to ~/Library/LaunchAgents or /Library/LaunchAgents (whichever it finds first)
 uninstall [name]        Uninstall [name] from ~/Library/LaunchAgents or /Library/LaunchAgents (whichever it finds first)
 show [pattern]          Show the contents of the launchctl daemon file
 edit [pattern]          Open the launchctl daemon file in the default editor (EDITOR environment variable)
-w will persist the start/stop command so the agent will load on startup or never load, respectively.
-l will display absolute paths of the launchctl daemon files when showing list of installed agents.
-x will force exact matching of the [pattern] for any command that uses a pattern
Example:
 lunchy ls
 lunchy ls -l nginx
 lunchy start -w redis
 lunchy stop mongo
 lunchy status mysql
 lunchy install /usr/local/Cellar/redis/2.2.2/io.redis.redis-server.plist
 lunchy show redis
 lunchy edit mongo
 lunchy uninstall -x elasticsearch # will not try to uninstall elasticsearch14
Note: if you run lunchy as root, you can manage daemons in /Library/LaunchDaemons also.
EOS
end
option_parser.parse!


op = ARGV.shift
if OPERATIONS.include?(op)
  begin
    Lunchy.new.send(op.to_sym, ARGV)
  rescue ArgumentError => ex
    puts ex.message
  rescue Exception => e
    puts "Uh oh, I didn't expect this:"
    puts e.message
    puts e.backtrace.join("\n")
  end
else
  puts option_parser.help
end
