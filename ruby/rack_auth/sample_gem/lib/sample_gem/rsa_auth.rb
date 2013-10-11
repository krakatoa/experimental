require 'cgi'
require 'openssl'
require 'base64'

require 'xmpp4r'

module SampleGem
  class RsaAuth
    @@sender_jid = Jabber::JID.new('fercho@localhost')
    @@client = Jabber::Client.new(@@sender_jid)
    @@client.connect('192.168.1.107')
    @@client.auth('')
    @@receiver_jid = Jabber::JID.new("otro@localhost")

    def initialize(app)
      @app = app
    end

    def call(env)
      #$stdout.puts "PRE"
      start = Time.now
      result = @app.call(env)
      stop = Time.now

      $stdout.puts "IsValid?: #{signature_is_valid?(env)}"
      message = Jabber::Message::new(@@receiver_jid, "Hola, tarde #{stop - start}s. [#{env}] (desde Rails)").set_type(:normal).set_id('1')
      @@client.send(message)
      result
    end

    def signature_is_valid?(env)
      key = OpenSSL::PKey::RSA.new(IO.read("../key.pub"))

      req = Rack::Request.new(env)
      verb = env["REQUEST_METHOD"]
      host = env["REMOTE_HOST"] || "localhost"
      path = env["REQUEST_PATH"]
      body = env["rack.input"].read
      sig = Base64.decode64(CGI.unescape(env["HTTP_X_AUTH_SIG"] || ""))
      return false if sig == ""

      sorted_params = req.params.sort.map {|param| param.join("=")}
      canonicalized_params = sorted_params.join("&")
      $stdout.puts "VERB: #{verb}"
      $stdout.puts "HOST: #{host}"
      $stdout.puts "PATH: #{path}"
      $stdout.puts "CANON: #{canonicalized_params}"
      expected_string = verb + host + path + canonicalized_params

      expected_string == key.public_decrypt(sig)
    end
  end
end
