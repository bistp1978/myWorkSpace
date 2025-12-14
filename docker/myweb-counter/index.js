const express = require('express');
const redis = require('redis');
const app = express();
const port = 8000;
const process = require('process');

const client = redis.createClient({ url: 'redis://redis-server:6379' });

client.on('error', (err) => {
    console.log('Redis error: ', err);
});

client.connect();
client.set('visits', 0);


app.get('/', async (req, res) => {
    console.log('Received GET request for /');

    let visits = await client.get('visits');
    res.send('Number of ' + visits + ' visits to this page ');
    await client.set('visits', parseInt(visits) + 1);
});
   

app.listen(port, () => {
    console.log(`My Web Counter App listening on port ${port}`);
})