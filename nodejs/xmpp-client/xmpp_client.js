var xmpp = require('node-xmpp');

var xmppClient = function(params) {
  var cl = new xmpp.Client({
    jid: params.jid,
    password: params.password,
    host: params.host,
    port: params.port
  });

  cl.on('online', function() {
    console.log("online");
    cl.send(new xmpp.Element('presence'));
  });
  
  var _this = this;
  cl.on('stanza', function(stanza) {
    if (stanza.is('message') && stanza.attrs.type !== 'error') {
      if (stanza.c('body')) {
        if (_this.onMessage) {
          var message = {
            from: stanza.attrs.from,
            body: stanza.getChild('body').getText()
          }
          _this.onMessage.call(this, message);
        }
  
        // reply back
        /*
          stanza.attrs.to = stanza.attrs.from;
          delete stanza.attrs.from;
          // and send back.
          cl.send(stanza);
        */
      }
    }
  });

  cl.on('error', function(e) {
    console.error(e);
    process.exit(1);
  });

  this.sendMessage = function(msg, destination) {
    console.log("will send to <" + destination + ">:" + msg);
    cl.send(new xmpp.Element('message', 
      {
        to: destination,
        type: "chat"}).
      c("body").
      t(msg));
  };

  this.close = function() {
    cl.end();
  }
}

module.exports = function(params) {
  return new xmppClient(params);
}
