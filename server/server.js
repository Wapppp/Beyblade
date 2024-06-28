// server.js
const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 64297;
const CHALLONGE_API_KEY = 'aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa'; // Replace with your Challonge API key

app.use(bodyParser.json());

// Proxy POST request to Challonge API
app.post('/', async (req, res) => {
  try {
    const apiUrl = 'https://api.challonge.com/v1/tournaments.json';
    const basicAuth = `Basic ${Buffer.from(`username:${CHALLONGE_API_KEY}`).toString('base64')}`;
    const response = await axios.post(apiUrl, req.body, {
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    res.json(response.data);
  } catch (error) {
    console.error('Error creating tournament:', error);
    res.status(500).json({ error: 'Failed to create tournament' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
