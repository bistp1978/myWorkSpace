const express = require('express');
//const path = require('path');
const app = express();
const port = 8070;
app.get('/', (req, res) => {
    res.send('Hello Hello !');
});

app.listen(port, () => {
    console.log(`My Web App listening on port ${port}`);
});