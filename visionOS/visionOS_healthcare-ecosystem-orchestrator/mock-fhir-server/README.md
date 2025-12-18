# Mock FHIR R4 Server

A lightweight mock FHIR R4 server for integration testing with the Healthcare Ecosystem Orchestrator visionOS application.

## Features

- ✅ **FHIR R4 compliant** resources (Patient, Observation, Encounter, MedicationRequest, Practitioner)
- 🔐 **OAuth 2.0** authentication simulation
- 🔍 **Search parameters** support
- ⚡ **Fast** and **lightweight** (Node.js + Express)
- 📦 **Docker ready**
- 🧪 **Test-friendly** with sample data

## Quick Start

### Prerequisites

- Node.js 18+ and npm 9+

### Installation

```bash
cd mock-fhir-server
npm install
```

### Configuration

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env` with your settings (optional).

### Running the Server

**Development mode** (with auto-reload):
```bash
npm run dev
```

**Production mode**:
```bash
npm start
```

Server will start on `http://localhost:3000`

### Docker

```bash
docker build -t mock-fhir-server .
docker run -p 3000:3000 mock-fhir-server
```

## Authentication

The server supports OAuth 2.0 **password** and **client_credentials** grant types.

### Getting a Token

**User authentication** (password grant):
```bash
curl -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "password",
    "username": "doctor@hospital.org",
    "password": "password123"
  }'
```

**System authentication** (client_credentials grant):
```bash
curl -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "client_credentials",
    "client_id": "healthcare-orchestrator",
    "client_secret": "mock-secret"
  }'
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 86400,
  "scope": "patient/*.read patient/*.write"
}
```

### Test Credentials

| Role | Username | Password | Scope |
|------|----------|----------|-------|
| Doctor | doctor@hospital.org | password123 | patient/*.read patient/*.write |
| Nurse | nurse@hospital.org | password123 | patient/*.read observation/*.read |
| Admin | admin@hospital.org | password123 | patient/*.* observation/*.* encounter/*.* |
| System | healthcare-orchestrator (client_id) | mock-secret (client_secret) | system/*.* |

## API Endpoints

### Metadata

```bash
# Get server capabilities
GET /fhir/metadata
```

### Patient

```bash
# Search patients
GET /fhir/Patient?name=John&_count=10

# Get specific patient
GET /fhir/Patient/patient-001

# Create patient
POST /fhir/Patient

# Update patient
PUT /fhir/Patient/patient-001

# Delete patient
DELETE /fhir/Patient/patient-001
```

**Search Parameters:**
- `_id` - Patient ID
- `identifier` - Medical Record Number
- `name` - Patient name (partial match)
- `family` - Family name
- `given` - Given name
- `gender` - male, female, other, unknown
- `birthdate` - Date of birth (YYYY-MM-DD)
- `_count` - Results per page (default: 10)
- `_offset` - Pagination offset

### Observation

```bash
# Search observations
GET /fhir/Observation?patient=patient-001&category=vital-signs

# Get specific observation
GET /fhir/Observation/obs-001

# Create observation
POST /fhir/Observation
```

**Search Parameters:**
- `patient` - Patient reference (e.g., patient-001)
- `category` - Observation category (e.g., vital-signs, laboratory)
- `code` - LOINC code (e.g., 8867-4 for heart rate)

### Encounter

```bash
# Search encounters
GET /fhir/Encounter?patient=patient-001&status=in-progress

# Get specific encounter
GET /fhir/Encounter/enc-001
```

### Medication

```bash
# Search medication requests
GET /fhir/MedicationRequest?patient=patient-001&status=active

# Get specific medication request
GET /fhir/MedicationRequest/med-001
```

### Practitioner

```bash
# Search practitioners
GET /fhir/Practitioner

# Get specific practitioner
GET /fhir/Practitioner/pract-001
```

## Example Usage

### Complete Workflow

1. **Get access token:**
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"grant_type":"password","username":"doctor@hospital.org","password":"password123"}' \
  | jq -r '.access_token')
```

2. **Search for patients:**
```bash
curl http://localhost:3000/fhir/Patient?name=John \
  -H "Authorization: Bearer $TOKEN"
```

3. **Get patient details:**
```bash
curl http://localhost:3000/fhir/Patient/patient-001 \
  -H "Authorization: Bearer $TOKEN"
```

4. **Get patient observations:**
```bash
curl http://localhost:3000/fhir/Observation?patient=patient-001 \
  -H "Authorization: Bearer $TOKEN"
```

5. **Create new observation:**
```bash
curl -X POST http://localhost:3000/fhir/Observation \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "resourceType": "Observation",
    "status": "final",
    "code": {
      "coding": [{
        "system": "http://loinc.org",
        "code": "8867-4",
        "display": "Heart rate"
      }]
    },
    "subject": {
      "reference": "Patient/patient-001"
    },
    "effectiveDateTime": "2025-11-17T12:00:00Z",
    "valueQuantity": {
      "value": 85,
      "unit": "beats/minute",
      "system": "http://unitsofmeasure.org",
      "code": "/min"
    }
  }'
```

## Testing

```bash
npm test
```

## Project Structure

```
mock-fhir-server/
├── src/
│   ├── server.js              # Main server file
│   ├── routes/                # FHIR resource routes
│   │   ├── auth.js            # OAuth 2.0 authentication
│   │   ├── patient.js         # Patient resource
│   │   ├── observation.js     # Observation resource
│   │   ├── encounter.js       # Encounter resource
│   │   ├── medication.js      # Medication resource
│   │   ├── practitioner.js    # Practitioner resource
│   │   └── metadata.js        # Capability statement
│   ├── middleware/            # Express middleware
│   │   ├── auth.js            # JWT validation
│   │   ├── errorHandler.js    # Error handling
│   │   └── requestLogger.js   # Request logging
│   └── data/                  # Sample data
│       ├── patients.json      # Sample patients
│       └── observations.json  # Sample observations
├── package.json
├── Dockerfile
├── .env.example
└── README.md
```

## FHIR Compliance

This mock server implements a subset of FHIR R4:

- **Resources**: Patient, Observation, Encounter, MedicationRequest, Practitioner
- **Interactions**: read, search-type, create, update, delete (varies by resource)
- **Search**: Basic search parameters
- **Format**: JSON only (application/fhir+json)
- **Bundle**: searchset and history types
- **OperationOutcome**: Error responses

## Limitations

- **In-memory storage** - Data is lost on restart
- **No validation** - Minimal FHIR validation
- **Simple auth** - OAuth simulation only, not production-ready
- **No subscriptions** - WebSocket/webhooks not implemented
- **No transactions** - Batch/transaction bundles not supported

## Production Use

⚠️ **This is a mock server for testing only!** Do not use in production. For production FHIR servers, consider:

- [HAPI FHIR](https://hapifhir.io/)
- [IBM FHIR Server](https://github.com/IBM/FHIR)
- [Microsoft FHIR Server](https://github.com/microsoft/fhir-server)
- [Google Cloud Healthcare API](https://cloud.google.com/healthcare)

## Contributing

Contributions welcome! Please open an issue or pull request.

## License

MIT

## Support

For issues or questions, please open a GitHub issue.
