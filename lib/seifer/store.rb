require 'pathname'

module Seifer
  class Store
    attr_reader :path

    def initialize(path)
      @path = Pathname.new(path)
    end

    def [](name)
      value_path = value_path(name)
      decryptor = Decryptor.from_json(value_path.read, key)
      Data.new(decryptor.decrypted_data)
    end

    def []=(name, value)
      validate_name!(name)
      encryptor = Encryptor.new(value, key)
      open(value_path(name), 'w', 0600) do |io|
        io.puts encryptor.to_json
      end
    end

    def key
      @key ||= key_path.read
    end

    def key_path
      path.join('.secret_key')
    end

    def value_path(name)
      path.join(name.to_s)
    end

    private

    def validate_name!(name)
      fail ArgumentError, 'name must contain only [a-zA-Z0-9_]' if name.to_s =~ /\W/
    end

    class Data < String
      def copy(path, mode: 0600)
        open(path, 'w', mode) do |io|
          io.puts self
        end
      end
    end
  end
end
