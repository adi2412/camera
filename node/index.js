var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var fs = require('fs');
var moment = require('moment');

var connectedDevices = 0;
app.use(express.static('public'));
app.get('/', function(req,res){
  res.sendFile(__dirname + '/index.html');
});

app.get('/admin', function(req,res){
  res.sendFile(__dirname + '/admin.html');
});

io.on('connection', function(socket){
  connectedDevices++;
  io.emit('newDevice', {devices: connectedDevices});
  socket.on('download', function(msg){
    io.emit('download', msg);
  });
  socket.on('clicked', function(msg){
    io.emit('clicked',msg);
  });
  socket.on('upload', function(msg){
    io.emit('upload', msg);
    // Write the files to disk
    var deivceName = msg.hostName;
    var imagesSaved = 0;
    for (var i = msg.images.length - 1; i >= 0; i--) {
      var now = moment();
      var timestamp = now.format('YYYYMMDDHHmmss')
      var imageName = deivceName + '-' + timestamp + '.jpg';
      fs.writeFile(imageName,msg.images[i],'base64',(err) =>{
        if(err) throw err;
        var saveMsg = deviceName + ' - ' + (++imagesSaved)+'/'+msg.images.length+' images saved.';
        io.emit('save',saveMsg);
      });
    }
  });
  socket.on('disconnect', function(msg){
    connectedDevices--;
    io.emit('disconnectedDevice', {devices: connectedDevices});
  });
});

http.listen(3000, function(){
  console.log("Server listening on port 3000");
});

// Methods to emit click event to all devices
// Methods to emit download event to all devices
// Receive the download files- POST request to a URL with the data?
// Read in the byte stream data on node server side
// Or send directly to the client admin? Doesn't make sense. I'm unable to download any files on the client side.
// send photos with correct name for photo