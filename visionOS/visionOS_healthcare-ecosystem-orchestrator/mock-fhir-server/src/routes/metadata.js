const express = require('express');
const router = express.Router();

const capabilityStatement = {
  resourceType: 'CapabilityStatement',
  status: 'active',
  date: '2025-11-17',
  publisher: 'Healthcare Orchestrator Team',
  kind: 'instance',
  software: { name: 'Mock FHIR Server', version: '1.0.0' },
  implementation: { description: 'Mock FHIR R4 Server for Integration Testing', url: 'http://localhost:3000/fhir' },
  fhirVersion: '4.0.1',
  format: ['json', 'application/fhir+json'],
  rest: [{
    mode: 'server',
    security: { cors: true, service: [{ coding: [{ system: 'http://terminology.hl7.org/CodeSystem/restful-security-service', code: 'OAuth' }] }] },
    resource: [
      {
        type: 'Patient',
        interaction: [{ code: 'read' }, { code: 'search-type' }, { code: 'create' }, { code: 'update' }, { code: 'delete' }],
        searchParam: [
          { name: '_id', type: 'token' },
          { name: 'identifier', type: 'token' },
          { name: 'name', type: 'string' },
          { name: 'family', type: 'string' },
          { name: 'given', type: 'string' },
          { name: 'gender', type: 'token' },
          { name: 'birthdate', type: 'date' }
        ]
      },
      {
        type: 'Observation',
        interaction: [{ code: 'read' }, { code: 'search-type' }, { code: 'create' }],
        searchParam: [{ name: 'patient', type: 'reference' }, { name: 'category', type: 'token' }, { name: 'code', type: 'token' }]
      },
      {
        type: 'Encounter',
        interaction: [{ code: 'read' }, { code: 'search-type' }],
        searchParam: [{ name: 'patient', type: 'reference' }, { name: 'status', type: 'token' }]
      },
      {
        type: 'MedicationRequest',
        interaction: [{ code: 'read' }, { code: 'search-type' }],
        searchParam: [{ name: 'patient', type: 'reference' }, { name: 'status', type: 'token' }]
      },
      {
        type: 'Practitioner',
        interaction: [{ code: 'read' }, { code: 'search-type' }]
      }
    ]
  }]
};

router.get('/', (req, res) => res.json(capabilityStatement));

module.exports = router;
