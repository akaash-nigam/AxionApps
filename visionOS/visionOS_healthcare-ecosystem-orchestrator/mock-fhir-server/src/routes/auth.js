/**
 * Authentication Routes
 * OAuth 2.0 token endpoint simulation
 */

const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'mock-fhir-secret-key-change-in-production';
const TOKEN_EXPIRY = '24h';

// Mock users database
const users = [
  {
    username: 'doctor@hospital.org',
    password: 'password123', // In real system, this would be hashed
    role: 'Practitioner',
    scope: 'patient/*.read patient/*.write'
  },
  {
    username: 'nurse@hospital.org',
    password: 'password123',
    role: 'Nurse',
    scope: 'patient/*.read observation/*.read'
  },
  {
    username: 'admin@hospital.org',
    password: 'password123',
    role: 'Administrator',
    scope: 'patient/*.* observation/*.* encounter/*.*'
  }
];

/**
 * POST /auth/token
 * OAuth 2.0 token endpoint
 *
 * Supports grant types:
 * - password (Resource Owner Password Credentials)
 * - client_credentials
 */
router.post('/token', (req, res) => {
  const { grant_type, username, password, client_id, client_secret, scope } = req.body;

  if (!grant_type) {
    return res.status(400).json({
      error: 'invalid_request',
      error_description: 'grant_type is required'
    });
  }

  // Password grant (user authentication)
  if (grant_type === 'password') {
    if (!username || !password) {
      return res.status(400).json({
        error: 'invalid_request',
        error_description: 'username and password are required'
      });
    }

    const user = users.find(u => u.username === username && u.password === password);

    if (!user) {
      return res.status(401).json({
        error: 'invalid_grant',
        error_description: 'Invalid username or password'
      });
    }

    const token = jwt.sign({
      sub: user.username,
      role: user.role,
      scope: user.scope
    }, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });

    return res.json({
      access_token: token,
      token_type: 'Bearer',
      expires_in: 86400, // 24 hours in seconds
      scope: user.scope,
      user: {
        username: user.username,
        role: user.role
      }
    });
  }

  // Client credentials grant (system authentication)
  if (grant_type === 'client_credentials') {
    if (!client_id || !client_secret) {
      return res.status(400).json({
        error: 'invalid_request',
        error_description: 'client_id and client_secret are required'
      });
    }

    // Mock client validation
    if (client_id === 'healthcare-orchestrator' && client_secret === 'mock-secret') {
      const token = jwt.sign({
        sub: client_id,
        role: 'System',
        scope: scope || 'system/*.*'
      }, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });

      return res.json({
        access_token: token,
        token_type: 'Bearer',
        expires_in: 86400,
        scope: scope || 'system/*.*'
      });
    }

    return res.status(401).json({
      error: 'invalid_client',
      error_description: 'Invalid client credentials'
    });
  }

  res.status(400).json({
    error: 'unsupported_grant_type',
    error_description: `Grant type '${grant_type}' is not supported. Use 'password' or 'client_credentials'`
  });
});

/**
 * GET /auth/info
 * Get authentication information (for testing)
 */
router.get('/info', (req, res) => {
  res.json({
    tokenEndpoint: '/auth/token',
    supportedGrantTypes: ['password', 'client_credentials'],
    testCredentials: {
      doctor: {
        username: 'doctor@hospital.org',
        password: 'password123',
        scope: 'patient/*.read patient/*.write'
      },
      nurse: {
        username: 'nurse@hospital.org',
        password: 'password123',
        scope: 'patient/*.read observation/*.read'
      },
      system: {
        client_id: 'healthcare-orchestrator',
        client_secret: 'mock-secret',
        scope: 'system/*.*'
      }
    },
    example: {
      curl: `curl -X POST http://localhost:3000/auth/token \\
  -H "Content-Type: application/json" \\
  -d '{"grant_type":"password","username":"doctor@hospital.org","password":"password123"}'`
    }
  });
});

module.exports = router;
