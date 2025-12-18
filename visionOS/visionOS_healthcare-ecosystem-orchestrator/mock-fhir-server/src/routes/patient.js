/**
 * Patient Resource Routes
 * FHIR R4 Patient resource implementation
 */

const express = require('express');
const { v4: uuidv4 } = require('uuid');
const router = express.Router();

// Load patient data
let patients = require('../data/patients.json');

/**
 * GET /fhir/Patient
 * Search patients with FHIR search parameters
 */
router.get('/', (req, res) => {
  const {
    _id,
    identifier,
    name,
    family,
    given,
    gender,
    birthdate,
    _count = '10',
    _offset = '0'
  } = req.query;

  let filteredPatients = [...patients];

  // Filter by ID
  if (_id) {
    filteredPatients = filteredPatients.filter(p => p.id === _id);
  }

  // Filter by identifier (MRN)
  if (identifier) {
    filteredPatients = filteredPatients.filter(p =>
      p.identifier.some(i => i.value === identifier)
    );
  }

  // Filter by name (partial match)
  if (name) {
    const searchName = name.toLowerCase();
    filteredPatients = filteredPatients.filter(p =>
      p.name.some(n =>
        `${n.given?.join(' ')} ${n.family}`.toLowerCase().includes(searchName)
      )
    );
  }

  // Filter by family name
  if (family) {
    const searchFamily = family.toLowerCase();
    filteredPatients = filteredPatients.filter(p =>
      p.name.some(n => n.family?.toLowerCase().includes(searchFamily))
    );
  }

  // Filter by given name
  if (given) {
    const searchGiven = given.toLowerCase();
    filteredPatients = filteredPatients.filter(p =>
      p.name.some(n =>
        n.given?.some(g => g.toLowerCase().includes(searchGiven))
      )
    );
  }

  // Filter by gender
  if (gender) {
    filteredPatients = filteredPatients.filter(p => p.gender === gender.toLowerCase());
  }

  // Filter by birthdate
  if (birthdate) {
    filteredPatients = filteredPatients.filter(p => p.birthDate === birthdate);
  }

  // Pagination
  const count = parseInt(_count, 10);
  const offset = parseInt(_offset, 10);
  const total = filteredPatients.length;
  const paginatedPatients = filteredPatients.slice(offset, offset + count);

  // Build FHIR Bundle response
  const bundle = {
    resourceType: 'Bundle',
    type: 'searchset',
    total: total,
    link: [
      {
        relation: 'self',
        url: `${req.protocol}://${req.get('host')}${req.originalUrl}`
      }
    ],
    entry: paginatedPatients.map(patient => ({
      fullUrl: `${req.protocol}://${req.get('host')}/fhir/Patient/${patient.id}`,
      resource: patient,
      search: {
        mode: 'match'
      }
    }))
  };

  // Add next/previous links if applicable
  if (offset + count < total) {
    bundle.link.push({
      relation: 'next',
      url: `${req.protocol}://${req.get('host')}/fhir/Patient?_count=${count}&_offset=${offset + count}`
    });
  }

  if (offset > 0) {
    bundle.link.push({
      relation: 'previous',
      url: `${req.protocol}://${req.get('host')}/fhir/Patient?_count=${count}&_offset=${Math.max(0, offset - count)}`
    });
  }

  res.json(bundle);
});

/**
 * GET /fhir/Patient/:id
 * Read a specific patient by ID
 */
router.get('/:id', (req, res) => {
  const patient = patients.find(p => p.id === req.params.id);

  if (!patient) {
    return res.status(404).json({
      resourceType: 'OperationOutcome',
      issue: [{
        severity: 'error',
        code: 'not-found',
        diagnostics: `Patient with ID '${req.params.id}' not found`
      }]
    });
  }

  res.json(patient);
});

/**
 * POST /fhir/Patient
 * Create a new patient
 */
router.post('/', (req, res) => {
  const newPatient = req.body;

  // Validate resource type
  if (newPatient.resourceType !== 'Patient') {
    return res.status(400).json({
      resourceType: 'OperationOutcome',
      issue: [{
        severity: 'error',
        code: 'invalid',
        diagnostics: 'Resource must be of type Patient'
      }]
    });
  }

  // Generate ID if not provided
  if (!newPatient.id) {
    newPatient.id = `patient-${uuidv4()}`;
  }

  // Add metadata
  newPatient.meta = {
    lastUpdated: new Date().toISOString(),
    versionId: '1'
  };

  patients.push(newPatient);

  res.status(201)
    .location(`/fhir/Patient/${newPatient.id}`)
    .json(newPatient);
});

/**
 * PUT /fhir/Patient/:id
 * Update an existing patient
 */
router.put('/:id', (req, res) => {
  const index = patients.findIndex(p => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({
      resourceType: 'OperationOutcome',
      issue: [{
        severity: 'error',
        code: 'not-found',
        diagnostics: `Patient with ID '${req.params.id}' not found`
      }]
    });
  }

  const updatedPatient = req.body;
  updatedPatient.id = req.params.id;

  // Update metadata
  const currentVersion = parseInt(patients[index].meta?.versionId || '0', 10);
  updatedPatient.meta = {
    lastUpdated: new Date().toISOString(),
    versionId: (currentVersion + 1).toString()
  };

  patients[index] = updatedPatient;

  res.json(updatedPatient);
});

/**
 * PATCH /fhir/Patient/:id
 * Partially update a patient
 */
router.patch('/:id', (req, res) => {
  const index = patients.findIndex(p => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({
      resourceType: 'OperationOutcome',
      issue: [{
        severity: 'error',
        code: 'not-found',
        diagnostics: `Patient with ID '${req.params.id}' not found`
      }]
    });
  }

  // Merge changes
  const patchedPatient = {
    ...patients[index],
    ...req.body,
    id: req.params.id // Ensure ID doesn't change
  };

  // Update metadata
  const currentVersion = parseInt(patients[index].meta?.versionId || '0', 10);
  patchedPatient.meta = {
    lastUpdated: new Date().toISOString(),
    versionId: (currentVersion + 1).toString()
  };

  patients[index] = patchedPatient;

  res.json(patchedPatient);
});

/**
 * DELETE /fhir/Patient/:id
 * Delete a patient
 */
router.delete('/:id', (req, res) => {
  const index = patients.findIndex(p => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({
      resourceType: 'OperationOutcome',
      issue: [{
        severity: 'error',
        code: 'not-found',
        diagnostics: `Patient with ID '${req.params.id}' not found`
      }]
    });
  }

  patients.splice(index, 1);

  res.status(204).send();
});

/**
 * GET /fhir/Patient/:id/_history
 * Get patient history (mock implementation)
 */
router.get('/:id/_history', (req, res) => {
  const patient = patients.find(p => p.id === req.params.id);

  if (!patient) {
    return res.status(404).json({
      resourceType: 'OperationOutcome',
      issue: [{
        severity: 'error',
        code: 'not-found',
        diagnostics: `Patient with ID '${req.params.id}' not found`
      }]
    });
  }

  // Return current version as history
  res.json({
    resourceType: 'Bundle',
    type: 'history',
    total: 1,
    entry: [{
      fullUrl: `${req.protocol}://${req.get('host')}/fhir/Patient/${patient.id}`,
      resource: patient,
      request: {
        method: 'GET',
        url: `Patient/${patient.id}`
      },
      response: {
        status: '200',
        lastModified: patient.meta?.lastUpdated
      }
    }]
  });
});

module.exports = router;
