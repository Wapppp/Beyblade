const express = require('express');
const https = require('https');
const bodyParser = require('body-parser');
const cors = require('cors');
const axios = require('axios');
const xml2js = require('xml2js');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

app.get('/tournament/:tournamentId/matches', async (req, res) => {
  const { tournamentId } = req.params;

  try {
    const response = await axios.get(
      `https://api.challonge.com/v1/tournaments/${tournamentId}/matches.json`,
      {
        params: {
          api_key: 'aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa',
        },
      }
    );

    res.json(response.data);
  } catch (error) {
    console.error(`Error fetching matches: ${error}`);
    res.status(500).json({ error: 'Error fetching matches' });
  }
});

// Get tournament details
app.get('/tournament/:id', async (req, res) => {
  const tournamentId = req.params.id;

  try {
    const response = await axios.get(`https://api.challonge.com/v1/tournaments/${tournamentId}.json`, {
      params: {
        api_key: 'aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa'
      }
    });
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching tournament:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Get participants of a tournament
app.get('/tournament/:id/participants', async (req, res) => {
  const tournamentId = req.params.id;

  try {
    const response = await axios.get(`https://api.challonge.com/v1/tournaments/${tournamentId}/participants.json`, {
      params: {
        api_key: 'aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa'
      }
    });
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching participants:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Get matches of a tournament
app.get('/tournament/:id/matches', async (req, res) => {
  const tournamentId = req.params.id;

  try {
    const response = await axios.get(`https://api.challonge.com/v1/tournaments/${tournamentId}/matches.json`, {
      params: {
        api_key: 'aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa'
      }
    });
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching matches:', error);
    res.status(500).send('Internal Server Error');
  }
});

app.get('/fetch-svg', async (req, res) => {
  const svgUrl = req.query.url;

  if (!svgUrl) {
    return res.status(400).send('URL is required');
  }

  try {
    const response = await axios.get(svgUrl, { responseType: 'text' });
    if (response.headers['content-type'] === 'image/svg+xml') {
      res.send(response.data);
    } else {
      res.status(400).send('Invalid SVG content');
    }
  } catch (error) {
    res.status(500).send('Error fetching SVG');
  }
});

// Proxy endpoint for fetching images from Challonge
app.get('/fetch-image', async (req, res) => {
  const imageUrl = req.query.url; // URL of the image to fetch from Challonge

  const options = {
    hostname: 'challonge.com',
    port: 443,
    path: imageUrl, // Use the full image URL here
    method: 'GET',
    headers: {
      'Content-Type': 'image/svg+xml', // Adjust content type as per your image type
    }
  };
  const apiReq = https.request(options, (apiRes) => {
    res.set('Access-Control-Allow-Origin', '*'); // Allow all origins
    apiRes.pipe(res);
  });

  apiReq.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
    res.status(500).send('Internal Server Error');
  });

  apiReq.end();
});
// POST start tournament bracket on Challonge
app.post('/tournaments/:tournamentId/start', async (req, res) => {
  const tournamentId = req.params.tournamentId;

  try {
    // Logic to start the tournament on Challonge
    const options = {
      hostname: 'api.challonge.com',
      port: 443,
      path: `/v1/tournaments/${tournamentId}/start.json?api_key=aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa`,
      method: 'POST',
    };

    const apiReq = https.request(options, (apiRes) => {
      let responseData = '';

      apiRes.on('data', (chunk) => {
        responseData += chunk;
      });

      apiRes.on('end', () => {
        res.status(apiRes.statusCode).json(JSON.parse(responseData));
      });
    });

    apiReq.on('error', (e) => {
      console.error(`Problem with request: ${e.message}`);
      res.status(500).send('Internal Server Error');
    });

    apiReq.end();
  } catch (error) {
    console.error('Error starting tournament bracket:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Get tournament details
app.get('/tournament/:id', async (req, res) => {
  const tournamentId = req.params.id;

  try {
    const options = {
      hostname: 'api.challonge.com',
      port: 443,
      path: `/v1/tournaments/${tournamentId}.json?api_key=aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa`,
      method: 'GET',
    };

    const apiReq = https.request(options, (apiRes) => {
      let responseData = '';

      apiRes.on('data', (chunk) => {
        responseData += chunk;
      });

      apiRes.on('end', () => {
        res.status(apiRes.statusCode).json(JSON.parse(responseData));
      });
    });

    apiReq.on('error', (e) => {
      console.error(`Problem with request: ${e.message}`);
      res.status(500).send('Internal Server Error');
    });

    apiReq.end();
  } catch (error) {
    console.error('Error fetching tournament:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Fetch all tournaments from Challonge
app.get('/tournaments', (req, res) => {
  try {
    const options = {
      hostname: 'api.challonge.com',
      port: 443,
      path: '/v1/tournaments.json?api_key=aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa',
      method: 'GET',
    };

    const apiReq = https.request(options, (apiRes) => {
      let responseData = '';

      apiRes.on('data', (chunk) => {
        responseData += chunk;
      });

      apiRes.on('end', () => {
        res.status(apiRes.statusCode).json(JSON.parse(responseData));
      });
    });

    apiReq.on('error', (e) => {
      console.error(`Problem with request: ${e.message}`);
      res.status(500).send('Internal Server Error');
    });

    apiReq.end();
  } catch (error) {
    console.error('Error fetching tournaments:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Create tournament endpoint
app.post('/create-tournament', (req, res) => {
  const data = JSON.stringify(req.body);
  const options = {
    hostname: 'api.challonge.com',
    port: 443,
    path: '/v1/tournaments.json?api_key=aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length,
    },
  };

  const apiReq = https.request(options, (apiRes) => {
    let responseData = '';

    apiRes.on('data', (chunk) => {
      responseData += chunk;
    });

    apiRes.on('end', () => {
      res.status(apiRes.statusCode).json(JSON.parse(responseData));
    });
  });

  apiReq.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
    res.status(500).send('Internal Server Error');
  });

  apiReq.write(data);
  apiReq.end();
});

// Add player to tournament
app.post('/add-player', (req, res) => {
  const { tournament_id, participant } = req.body;
  const data = JSON.stringify({ participant });
  const options = {
    hostname: 'api.challonge.com',
    port: 443,
    path: `/v1/tournaments/${tournament_id}/participants.json?api_key=aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length,
    },
  };

  const apiReq = https.request(options, (apiRes) => {
    let responseData = '';

    apiRes.on('data', (chunk) => {
      responseData += chunk;
    });

    apiRes.on('end', () => {
      res.status(apiRes.statusCode).json(JSON.parse(responseData));
    });
  });

  apiReq.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
    res.status(500).send('Internal Server Error');
  });

  apiReq.write(data);
  apiReq.end();
});

app.listen(port, () => {
  console.log(`Proxy server is running at http://localhost:${port}`);
});
// Proxy endpoint for fetching images from Challonge
app.get('/fetch-image', async (req, res) => {
  const imageUrl = req.query.url; // URL of the image to fetch from Challonge
  const options = {
    hostname: 'challonge.com',
    port: 443,
    path: imageUrl, // Use the full image URL here
    method: 'GET',
    headers: {
      'Content-Type': 'image/svg+xml', // Adjust content type as per your image type
    }
  };

  const apiReq = https.request(options, (apiRes) => {
    res.set('Access-Control-Allow-Origin', '*'); // Allow all origins
    apiRes.pipe(res);
  });

  apiReq.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
    res.status(500).send('Internal Server Error');
  });

  apiReq.end();
});
