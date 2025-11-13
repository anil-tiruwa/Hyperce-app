const express = require('express');
const client = require('prom-client'); // Prometheus client
const app = express();
const PORT = 3000;

// Collect default metrics (CPU, memory, etc.)
client.collectDefaultMetrics();

// Optional: a custom counter for requests
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestCounter.labels(req.method, req.path, res.statusCode).inc();
  });
  next();
});

app.get('/', (req, res) => {
  res.send('Hello from DevOps Test!');
  console.log('Request received on /');
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(PORT, () => {
  console.log('Server running on port ' + PORT);
});

