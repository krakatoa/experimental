var xmpp = require('node-xmpp');

var cl = new xmpp.Client({
  jid         : "<email>@gmail.com",
  password    : "<password>",
  host        : 'talk.google.com',
  oauth2_auth:  'https://www.googleapis.com/auth/googletalk',
  oauth2_token: 'ya29.AHES6ZR26sfz1PdavCHBc0BEA6NfEb0WZgpAvCPwd1Ap2WUjg9OUsQ',
  port        : 5222
});

cl.on('online', function() {
  console.log("online");
  cl.send(new xmpp.Element('presence'));
  cl.send(new xmpp.Element('message', 
    { to: "<destination>@gmail.com",
      type: "chat"}).
    c("body").
    t(":) (tambien desde nodejs)"));
});

cl.on('stanza', function(stanza) {
  if (stanza.is('message') && stanza.attrs.type !== 'error') {
    console.log(stanza);
    if (stanza.c('body')) {
      console.log(stanza.attrs.from + ":" + stanza.getChild('body').getText());
    }
  }
});

cl.addListener('error', function(e) {
  console.error(e);
  process.exit(1);
});
