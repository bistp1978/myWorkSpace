var fs = require('fs');
var path = require('path');
var MongoClient = require('mongodb').MongoClient;
var bodyParser = require('body-parser');
var express = require('express');
var app = express();
var port = 3000;
require('dotenv').config();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname + '/index.html'));
});

app.get('/profile-picture', function (req, res) {
  let img = fs.readFileSync(path.join(__dirname, "images/profile_1.jpg"));
  res.writeHead(200, {'Content-Type': 'image/jpg' });
  res.end(img, 'binary');
});


// use when starting application locally
let mongoUrlLocal = "mongodb://admin:password@localhost:27017";

// use when starting application as docker container
//let mongoUrlDocker = "mongodb://admin:password@my-mongo";
let mongoUrlDocker = process.env.MONGO_URL
console.log("Mongo URL: " + mongoUrlDocker);

// pass these options to mongo client connect request to avoid DeprecationWarning for current Server Discovery and Monitoring engine
let mongoClientOptions = { useNewUrlParser: true, useUnifiedTopology: true };

// "user-account" in demo with docker. "my-db" in demo with docker-compose
let databaseName = "user-account";


app.get('/get-profile', function(req, res) {
    let response = {};
    MongoClient.connect(mongoUrlDocker,mongoClientOptions,function(err, client) {
        if(err) throw err;
        let db = client.db(databaseName);
        let query = { userid: 1 };
        db.collection('users').findOne(query, function(err, result) {
            if (err) throw err;
            response = result;
            client.close();
            res.send(response ? response : {});

        });
    });
});

app.post('/update-profile', function(req, res) {
    let userObj = req.body;

    console.log("Connecting to database ... ");

    MongoClient.connect(mongoUrlDocker,mongoClientOptions, function(err, client) {
        if(err) throw err;
        let db = client.db(databaseName);
        userObj['userid'] = 1 ;
        let myquery = { userid: 1 };
        let newValues = { $set: userObj  };
        
        console.log("Successfully connected to user-accounts database.");
        
        db.collection('users').updateOne(myquery, newValues, {upsert: true}, function(err, res) {
            if (err) throw err;
            console.log("1 document updated, this is the only one for demo purposes.");
            client.close();
        });
    });
    res.send(userObj);
});

app.get('/profile-picture', function(req, res) {
    var img = fs.readFileSync('profile_1.jpg');
    res.writeHead(200, {'Content-Type': 'image/jpeg' });
    res.end(img, 'binary');
});

app.listen(3000, function () {
  console.log("app listening on port 3000!");
});

    