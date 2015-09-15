var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
app.use(express.static('public'));
app.get('/', function(req,res){
  res.sendFile(__dirname + '/index.html');
});

app.get('/admin', function(req,res){
  res.sendFile(__dirname + '/admin.html');
});

io.on('connection', function(socket){
  console.log("Connected client");
  socket.on('clickPic', function(msg){
    console.log("received click pic event");
    io.emit('clickPic', msg);
  });
  socket.on('download', function(msg){
    console.log("download event");
    io.emit('download', msg);
  });
  socket.on('upload', function(msg){
    console.log("image received");
    io.emit('upload', msg);
  })
});

http.listen(3000, function(){
  console.log("Server listening on port 3000");
});

// Methods to emit click event to all devices
// Methods to emit download event to all devices
// Receive the download files- POST request to a URL with the data?
// Read in the byte stream data on node server side
// Or send directly to the client admin? Doesn't make sense. I'm unable to download any files on the client side.