const keys = require('./keys');
const redis = require('redis');

const redisClient = redis.createClient({
    host: keys.redisHost,
    port: keys.redisPort,
    retry_strategy: options => {
        return Math.min(options.attempt * 100, 3000);
    }

});

const sub = redisClient.duplicate();

function fib(index) {
    if (index < 2) return 1;
    return fib(index - 1) + fib(index - 2);
}

sub.on('message', (channel, message) => {
    console.log('Received message:', message);
    const result = fib(parseInt(message));
    redisClient.hset('values', message, result);
});
sub.subscribe('insert');