var rl = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});

host = "192.168.1.107";
port = 5222;

params = {};
var xmppClient = null;
rl.question("which user?>", function(input) {
  params.jid = input;
  rl.question("which password?>", function(input) {
    params.password = input;
    params.host = host;
    params.port = port;
    rl.question("talk to: ", function(input) {
      xmppClient = new require('./xmpp_client')(params);
      xmppClient.destination = input;
      xmppClient.onMessage = function(msg) { console.log(msg.from + " said: " + msg.body); };
      rl.setPrompt("> ");
      rl.prompt();
    });
  });
});

rl.on('line', function(line) {
  switch(line.trim()) {
    case 'quit':
      rl.close();
      break;
    default:
      xmppClient.sendMessage(line, xmppClient.destination);
  }
  rl.prompt();
}).on('close', function() {
  console.log("Bye");
  process.exit(0);
});
