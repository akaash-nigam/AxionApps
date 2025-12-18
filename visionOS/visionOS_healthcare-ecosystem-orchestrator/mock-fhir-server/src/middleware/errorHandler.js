/**
 * Error Handler Middleware
 * Formats errors as FHIR OperationOutcome resources
 */

module.exports = (err, req, res, next) => {
  console.error('Error:', err);

  const statusCode = err.statusCode || 500;
  const severity = statusCode >= 500 ? 'error' : 'warning';

  res.status(statusCode).json({
    resourceType: 'OperationOutcome',
    issue: [{
      severity: severity,
      code: err.code || 'exception',
      diagnostics: err.message || 'An unexpected error occurred',
      details: process.env.NODE_ENV === 'development' ? {
        stack: err.stack
      } : undefined
    }]
  });
};
