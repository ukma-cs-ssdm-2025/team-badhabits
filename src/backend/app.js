const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./swagger');
const errorHandler = require('./middleware/errorHandler');
const { NotFoundError } = require('./utils/errors');
const analyticsRoutes = require('./routes/analytics');
const workoutsRoutes = require('./routes/workouts');
const recommendationsRoutes = require('./routes/recommendations');
// TypeScript routes for Lab 6 testing
const adaptiveTsRoutes = require('./routes/adaptive-ts');
const paymentsTsRoutes = require('./routes/payments-ts');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'Wellity Backend API',
    version: '1.0.0',
  });
});

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Wellity API Documentation',
}));

app.get('/api-docs-json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Use TypeScript routes for Lab 6 (override original routes for testing)
app.use('/api/v1/adaptive', adaptiveTsRoutes);
app.use('/api/v1/payments', paymentsTsRoutes);
// Original JavaScript routes (commented for testing)
// app.use('/api/v1/adaptive', adaptiveRoutes);
// app.use('/api/v1/payments', paymentsRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/workouts', workoutsRoutes);
app.use('/api/v1/recommendations', recommendationsRoutes);

app.get('/', (req, res) => {
  res.json({
    message: 'Wellity Backend API',
    version: '1.0.0',
    documentation: '/api-docs',
    endpoints: {
      adaptive: '/api/v1/adaptive/recommend',
      payments: '/api/v1/payments/subscribe',
      analytics: '/api/v1/analytics/trainer/:id',
      workoutVerification: '/api/v1/workouts/:id/verify',
      recoveryRecommendations: '/api/v1/recommendations/recovery',
    },
  });
});

// 404 Handler - must be BEFORE error handler
app.use((req, res, next) => {
  next(new NotFoundError('Endpoint not found'));
});

// Global Error Handler - must be LAST middleware
app.use(errorHandler);

// Only start server if this file is run directly (not imported)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Wellity Backend API running on http://localhost:${PORT}`);
    console.log(`API Documentation: http://localhost:${PORT}/api-docs`);
  });
}

module.exports = app;
