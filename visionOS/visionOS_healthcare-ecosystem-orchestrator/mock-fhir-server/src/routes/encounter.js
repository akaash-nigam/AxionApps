const express = require('express');
const router = express.Router();

const encounters = [{
  resourceType: 'Encounter',
  id: 'enc-001',
  status: 'in-progress',
  class: { system: 'http://terminology.hl7.org/CodeSystem/v3-ActCode', code: 'EMER', display: 'emergency' },
  subject: { reference: 'Patient/patient-001' },
  period: { start: '2025-11-17T08:00:00Z' }
}];

router.get('/', (req, res) => {
  const { patient, status } = req.query;
  let filtered = [...encounters];
  if (patient) filtered = filtered.filter(e => e.subject?.reference === `Patient/${patient}`);
  if (status) filtered = filtered.filter(e => e.status === status);

  res.json({
    resourceType: 'Bundle',
    type: 'searchset',
    total: filtered.length,
    entry: filtered.map(enc => ({ fullUrl: `${req.protocol}://${req.get('host')}/fhir/Encounter/${enc.id}`, resource: enc }))
  });
});

router.get('/:id', (req, res) => {
  const encounter = encounters.find(e => e.id === req.params.id);
  if (!encounter) return res.status(404).json({ resourceType: 'OperationOutcome', issue: [{ severity: 'error', code: 'not-found' }] });
  res.json(encounter);
});

module.exports = router;
