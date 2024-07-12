const express = require('express');
const https = require('https');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

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
