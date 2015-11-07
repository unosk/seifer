require 'openssl'
require 'json'

module Seifer
  module Encryptor
    def self.new(plaintext, key)
      Version1.new(plaintext, key)
    end

    class Version1
      attr_reader :plaintext, :encrypted_data, :iv, :auth_tag, :key

      def initialize(plaintext, key)
        @plaintext = plaintext
        @key = key
        cipher = OpenSSL::Cipher.new(ALGORITHM)
        cipher.encrypt
        cipher.key = @key
        @iv = cipher.random_iv
        cipher.auth_data = ''
        @encrypted_data = cipher.update(plaintext) + cipher.final
        @auth_tag = cipher.auth_tag
      end

      def cipher
        ALGORITHM
      end

      def version
        1
      end

      def to_json
        {
          encrypted_data: [encrypted_data].pack('m*'),
          iv: [iv].pack('m*'),
          auth_tag: [auth_tag].pack('m*'),
          cipher: cipher,
          version: version
        }.to_json
      end
    end
  end
end
