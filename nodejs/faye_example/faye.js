var zmq = require('zmq'),
  http = require('http'),
  faye = require('faye'),
  lru = require('lru-cache'),
  murmur3 = require('murmurhash3'),
  express = require('express');

app = express();

var subscriber = zmq.socket('sub');

var host = '127.0.0.1';
var port = process.argv[2] || 8000;

var cache = lru({
  max: 10,
  length: function(n) { return 1 },
  maxAge: 1000 * 3
});

subscriber.connect("tcp://127.0.0.1:4101");
subscriber.connect("tcp://127.0.0.1:4102");

var bayeux = new faye.NodeAdapter({
  mount: '/faye',
  timeout: 45
});

subscriber.subscribe('');

tokens = {
  "none-token": [],
  "a-token": ['/foo/a'],
  "b-token": ['/foo/b'],
  "a-b-token": ['/foo/a', '/foo/b']
}

var auth = {
  incoming: function(message, callback) {
    if (message.channel != '/meta/subscribe') {
      if (message.channel == "/meta/connect") {
        console.log(message);
      };
      return callback(message);
    } else {
      //console.log("subscription: " + message.ext.token);
      if (tokens[message.ext.token].indexOf(message.subscription) < 0) {
        message.error = "Invalid Token"; // If you add an error property to a message, the server will not process the message further and will simply return it to the sender, effectively blocking the subscription attempt
      }
      console.log(message);
      return callback(message);
    };
  },
  outgoing: function(message, callback) {
    /*if (message.channel == '/foo') {
      console.log("sending: " + message.clientId);
    };*/
    //console.log("sending to channel " + message.channel);
    callback(message);
  }
};
bayeux.addExtension(auth);

subscriber.on('message', function(msg) {
  //console.log('read: ' + msg.toString());
  var hsh = murmur3.murmur32Sync(msg.toString(), 197);
  console.log(cache.keys());
  if (!cache.get(hsh)) {
    cache.set(hsh, true);

    var json_msg = JSON.parse(msg.toString());
    var channel = null;
    if (json_msg.worker == 'A') {
      channel = 'a';
    } else if (json_msg.worker == 'B') {
      channel = 'b';
    };
    bayeux.getClient().publish('/foo/' + channel, {'status': json_msg});
  }
  
});

app.use(express.static(__dirname + "/static"));
/*
app.all("*", function(req, res, next) {
  //console.log(req.get('Upgrade'));
  console.log(req.headers);
  next();
});
*/
app.configure(function() {
  app.use(bayeux);
});

app.listen(port);
//bayeux.attach(app);
