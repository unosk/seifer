require 'openssl'
require 'json'

module Seifer
  module Decryptor
    def self.from_json(json, key)
      data = JSON.parse!(json)
      case data['version']
      when 1
        Version1.from_json_hash(data, key)
      else
        fail ArgumentError, "Unknown version #{data['version'].inspect}"
      end
    end

    class Version1
      attr_reader :decrypted_data, :encrypted_data, :iv, :auth_tag, :key

      def self.from_json_hash(data, key)
        new(
          data['encrypted_data'].unpack('m*')[0],
          data['iv'].unpack('m*')[0],
          data['auth_tag'].unpack('m*')[0],
          key
        )
      end

      def initialize(encrypted_data, iv, auth_tag, key)
        @encrypted_data = encrypted_data
        @iv = iv
        @auth_tag = auth_tag
        @key = key
        cipher = OpenSSL::Cipher.new(ALGORITHM)
        cipher.decrypt
        cipher.key = @key
        cipher.iv = @iv
        cipher.auth_data = ''
        cipher.auth_tag = @auth_tag
        @decrypted_data = cipher.update(@encrypted_data) + cipher.final
      end

      def cipher
        ALGORITHM
      end

      def version
        1
      end
    end
  end
end
