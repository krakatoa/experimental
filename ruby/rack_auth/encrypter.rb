require 'base64'
require 'openssl'
require 'cgi'

module Rask
  class Encrypter
    def self.encrypt(path, params)
      private_key = OpenSSL::PKey::RSA.new(File.read("key.pem"))
      
      sorted_params = params.sort.map {|param| param.join("=")}
      canonicalized_params = sorted_params.join("&")
      string_to_sign = "GET" + "localhost" + "/" + canonicalized_params

      unescaped_sig = private_key.private_encrypt(string_to_sign)
      sig = CGI.escape(Base64.encode64(unescaped_sig))
      sig
    end
  end
end
