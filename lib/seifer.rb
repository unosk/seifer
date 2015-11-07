require 'seifer/version'
require 'seifer/cli'
require 'seifer/store'
require 'seifer/encryptor'
require 'seifer/decryptor'

module Seifer
  ALGORITHM = 'aes-256-gcm'

  def self.new(path)
    Store.new(path)
  end
end
