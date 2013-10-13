config = {'iceServers': [{'url': 'turn:fedario%40gmail.com@numb.viagenie.ca', 'credential': 'jdjhthfjwap'}]};
offerAnswerConstraints = {optional: [], mandatory: {OfferToReceiveAudio: false, OfferToReceiveVideo: false}};
//config = {'iceServers': [{'url': 'stun:stun.l.google.com:19302'}]};

serializePeerData = function(session, iceCandidates) {
  var data = {
    session: { 'sdp': session.sdp, 'type': session.type },
    iceCandidates: iceCandidates
  };
  //console.log("serialized data: " + JSON.stringify(data));

  return escape(JSON.stringify(data));
};

deserializePeerData = function(serializedData) {
  var rawData = JSON.parse(unescape(serializedData));
  var serializedData = {
    session: new RTCSessionDescription(rawData.session),
    iceCandidates: []
  };
  rawData.iceCandidates.forEach(function(ice) {
    serializedData.iceCandidates.push(new RTCIceCandidate(ice));
  });
  return serializedData;
};

showPeerData = function(peerData, side) {
  document.getElementById("peerData" + side).value = peerData;
};
readPeerData = function(side) {
  return deserializePeerData(document.getElementById("peerData" + side).value);
};
hidePeerData = function(side) {
  document.getElementById("peerData" + side).style.display = "none";
};

appendToChat = function(nick, text) {
  var text = nick + " dice: " + text;

  var el = document.getElementById("chat");
  el.value = el.value + text + "\n";
};
receivedMessage = function(msg) {
  hidePeerData("A");
  hidePeerData("B");

  msg = JSON.parse(msg);
  appendToChat(msg.nick, msg.text);
};

aSide = function() {
var aSession = null;
aConnection = new webkitRTCPeerConnection(config, {optional: [{RtpDataChannels: true}]});

sendChannel = aConnection.createDataChannel("mychannel", {reliable: false});
sendChannel.onmessage = function(event) {
  //console.log(event);
  receivedMessage(event.data);
};

var aIceCandidates = []; aConnection.onicecandidate = function(event) {
  console.log(event);
  if(event.candidate) {
    aIceCandidates.push(event.candidate);
    //console.log(event.candidate.candidate.trim());
  } else {
    finishedGathering();
  };
};
finishedGathering = function() {
  //console.log("finished gathering ice candidates");
  aRawIce = [];
  aIceCandidates.forEach(function(c) {
    var data = {sdpMLineIndex: c.sdpMLineIndex, sdpMid: c.sdpMid, candidate: c.candidate};
    aRawIce.push(data);
    aIceCandidates = [];
  });
  
  var serialized = serializePeerData(aSession, aRawIce);
  showPeerData(serialized, "A");
  console.log("Wait for B");
};
/*
aConnection.ongatheringchange = function(event) {
  if(event.currentTarget.iceGatheringState == 'complete') {
    finishedGathering();
  };
};*/
/*
aConnection.onstatechange = function(event) {
  if(event.currentTarget.readyState == "stable") {
    hidePeerData("A");
    hidePeerData("B");
  };
};*/

gotADescription = function(desc) {
  aSession = desc;
  aConnection.setLocalDescription(aSession); // => trigerea icecandidates
}
aConnection.createOffer(gotADescription, null, offerAnswerConstraints);
};

bSide = function() {

var aData = readPeerData("A");
var aSession = aData.session;
var aIceCandidates = aData.iceCandidates;
//console.log(aSession);
//console.log(aIceCandidates);
var bSession = null;

bConnection = new webkitRTCPeerConnection(config, {optional: [{RtpDataChannels: true}]});
console.log("created connection");

bConnection.ondatachannel = function(event) {
  receiveChannel = event.channel;
  receiveChannel.onmessage = function(event) {
    receivedMessage(event.data);
  };
};

// first, setRemoteDescription, then addIceCandidates, by using the successCallback
console.log("settingRemoteDescription");
bConnection.setRemoteDescription(aSession, function() {
  aIceCandidates.forEach(function(ice) { bConnection.addIceCandidate(ice); });
});

var bIceCandidates = []; bConnection.onicecandidate = function(event) {
  //if(event.candidate) {
  if(event.currentTarget.iceGatheringState == "gathering") {
    bIceCandidates.push(event.candidate);
    //console.log(event.candidate.candidate.trim());
  } else if (event.currentTarget.iceGatheringState == "complete") {
    finishedGathering();
  };
};
finishedGathering = function() {
  console.log("finished gathering ice candidates");
  bRawIce = [];
  bIceCandidates.forEach(function(c) {
    var data = {sdpMLineIndex: c.sdpMLineIndex, sdpMid: c.sdpMid, candidate: c.candidate};
    //console.log(data);
    bRawIce.push(data);
    bIceCandidates = [];
  });
  
  var serialized = serializePeerData(bSession, bRawIce);
  showPeerData(serialized, "B");
  console.log("B is ready");
};
/*
bConnection.ongatheringchange = function(event) {
  // todo: puede pasar que se trigeree dos veces este evento,
  // en ese caso la conexion falla. lo que hay que hacer es volver a pasar el peerData
  if(event.currentTarget.iceGatheringState == 'complete') {
    finishedGathering();
  };
};*/
/*bConnection.onstatechange = function(event) {
  if(event.currentTarget.readyState == "stable") {
    hidePeerData("A");
  };
};*/

gotBDescription = function(desc) {
  bSession = desc;
  bConnection.setLocalDescription(bSession); // => trigerea icecandidates
}
bConnection.createAnswer(gotBDescription, null, offerAnswerConstraints);
}

finishASide = function() {
  var bData = readPeerData("B");
  var bSession = bData.session;
  var bIceCandidates = bData.iceCandidates;

  aConnection.setRemoteDescription(bSession, function() {
    bIceCandidates.forEach(function(ice) { aConnection.addIceCandidate(ice) });
    console.log("A is ready");
  });
};

trySend = function() {
  var currentChannel = null;
  if(!(typeof(sendChannel) == 'undefined')) { currentChannel = sendChannel; };
  if(!(typeof(receiveChannel) == 'undefined')) { currentChannel = receiveChannel; };

  var nick = document.getElementById("nick").value;
  var text = document.getElementById("chatText").value;

  var msg = { nick: nick, text: text};
  appendToChat(nick, text);
  currentChannel.send(JSON.stringify(msg));
}
