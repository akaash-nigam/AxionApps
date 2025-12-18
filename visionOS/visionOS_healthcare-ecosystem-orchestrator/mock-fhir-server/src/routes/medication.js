const express = require('express');
const router = express.Router();

const medications = [{
  resourceType: 'MedicationRequest',
  id: 'med-001',
  status: 'active',
  intent: 'order',
  medicationCodeableConcept: {
    coding: [{ system: 'http://www.nlm.nih.gov/research/umls/rxnorm', code: '197361', display: 'Lisinopril 10 MG Oral Tablet' }],
    text: 'Lisinopril 10mg'
  },
  subject: { reference: 'Patient/patient-001' },
  authoredOn: '2025-11-17T09:00:00Z',
  dosageInstruction: [{ text: 'Take 1 tablet by mouth daily', timing: { repeat: { frequency: 1, period: 1, periodUnit: 'd' } } }]
}];

router.get('/', (req, res) => {
  const { patient, status } = req.query;
  let filtered = [...medications];
  if (patient) filtered = filtered.filter(m => m.subject?.reference === `Patient/${patient}`);
  if (status) filtered = filtered.filter(m => m.status === status);

  res.json({
    resourceType: 'Bundle',
    type: 'searchset',
    total: filtered.length,
    entry: filtered.map(med => ({ fullUrl: `${req.protocol}://${req.get('host')}/fhir/MedicationRequest/${med.id}`, resource: med }))
  });
});

router.get('/:id', (req, res) => {
  const medication = medications.find(m => m.id === req.params.id);
  if (!medication) return res.status(404).json({ resourceType: 'OperationOutcome', issue: [{ severity: 'error', code: 'not-found' }] });
  res.json(medication);
});

module.exports = router;
