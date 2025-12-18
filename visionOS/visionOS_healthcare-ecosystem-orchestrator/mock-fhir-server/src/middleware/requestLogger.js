/**
 * Request Logger Middleware
 * Logs FHIR API requests for auditing
 */

const requestLog = [];

module.exports = (req, res, next) => {
  const startTime = Date.now();

  // Log response
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const logEntry = {
      timestamp: new Date().toISOString(),
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('user-agent'),
      user: req.user?.sub || 'anonymous'
    };

    requestLog.push(logEntry);

    // Keep only last 1000 requests
    if (requestLog.length > 1000) {
      requestLog.shift();
    }

    if (process.env.NODE_ENV !== 'test') {
      console.log(`[${logEntry.timestamp}] ${logEntry.method} ${logEntry.path} - ${logEntry.statusCode} (${logEntry.duration})`);
    }
  });

  next();
};

// Export function to get logs
module.exports.getLogs = () => requestLog;
