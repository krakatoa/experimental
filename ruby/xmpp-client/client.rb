require 'xmpp4r'

sender_jid = Jabber::JID.new('fercho@localhost')
client = Jabber::Client.new(sender_jid)
client.connect('192.168.1.107')
client.auth('')

#client.send(Jabber::Presence.new.set_show(:chat)).set_status('my status')

receiver_jid = Jabber::JID.new("otro@localhost")
message = Jabber::Message::new(receiver_jid, "Hola ! (desde Ruby)").set_type(:normal).set_id('1')
client.send(message)
