require 'thor'

module Seifer
  class Cli < Thor
    class_option :path, type: :string, required: true, desc: 'path to the directory for storing secrets and key'

    desc 'write VARNAME [VALUE]', 'write value (when VALUE is omitted, read from STDIN)'
    method_option :noecho, type: :boolean, desc: 'Ask one-line value with noecho when stdin is tty'
    def write(name, value = nil)
      value ||= if options[:noecho]
                  ask_noecho("#{name}: ")
                else
                  $stdin.read.chomp
                end
      store[name] = value
    end

    desc 'read VARNAME', 'read value'
    def read(name)
      value = store[name]
      if value
        puts value
      else
        exit 1
      end
    end

    private

    def store
      @store ||= Store.new(options[:path])
    end

    def ask_noecho(prompt)
      require 'io/console'
      print prompt
      $stdin.noecho { $stdin.gets.chomp }
    end
  end
end
