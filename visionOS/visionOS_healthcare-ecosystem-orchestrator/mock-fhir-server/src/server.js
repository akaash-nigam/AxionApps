/**
 * Mock FHIR R4 Server
 * Healthcare Ecosystem Orchestrator - Integration Testing
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');

// Import routes
const patientRoutes = require('./routes/patient');
const observationRoutes = require('./routes/observation');
const encounterRoutes = require('./routes/encounter');
const medicationRoutes = require('./routes/medication');
const practitionerRoutes = require('./routes/practitioner');
const metadataRoutes = require('./routes/metadata');
const authRoutes = require('./routes/auth');

// Import middleware
const authMiddleware = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');
const requestLogger = require('./middleware/requestLogger');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}
app.use(requestLogger);

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0',
    fhirVersion: 'R4'
  });
});

// FHIR capability statement (metadata)
app.use('/fhir/metadata', metadataRoutes);
app.use('/fhir', metadataRoutes);

// Authentication routes (OAuth 2.0 simulation)
app.use('/auth', authRoutes);

// Protected FHIR routes
app.use('/fhir/Patient', authMiddleware, patientRoutes);
app.use('/fhir/Observation', authMiddleware, observationRoutes);
app.use('/fhir/Encounter', authMiddleware, encounterRoutes);
app.use('/fhir/Medication', authMiddleware, medicationRoutes);
app.use('/fhir/MedicationRequest', authMiddleware, medicationRoutes);
app.use('/fhir/Practitioner', authMiddleware, practitionerRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Healthcare Orchestrator Mock FHIR Server',
    fhirVersion: 'R4',
    documentation: '/fhir/metadata',
    endpoints: {
      metadata: '/fhir/metadata',
      auth: '/auth/token',
      patients: '/fhir/Patient',
      observations: '/fhir/Observation',
      encounters: '/fhir/Encounter',
      medications: '/fhir/Medication',
      practitioners: '/fhir/Practitioner'
    }
  });
});

// Error handling
app.use(errorHandler);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    resourceType: 'OperationOutcome',
    issue: [{
      severity: 'error',
      code: 'not-found',
      diagnostics: `Resource not found: ${req.method} ${req.path}`
    }]
  });
});

// Start server
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🏥 Mock FHIR Server running on port ${PORT}`);
    console.log(`📖 Metadata: http://localhost:${PORT}/fhir/metadata`);
    console.log(`🔐 Auth: http://localhost:${PORT}/auth/token`);
    console.log(`💚 Health: http://localhost:${PORT}/health`);
  });
}

module.exports = app;
