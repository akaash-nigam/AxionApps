const express = require('express');
const router = express.Router();

const practitioners = [{
  resourceType: 'Practitioner',
  id: 'pract-001',
  identifier: [{ system: 'http://hospital.org/practitioners', value: 'NPI123456' }],
  active: true,
  name: [{ family: 'Johnson', given: ['Sarah'], prefix: ['Dr.'] }],
  telecom: [{ system: 'phone', value: '(555) 100-2000' }],
  gender: 'female',
  qualification: [{ code: { coding: [{ system: 'http://terminology.hl7.org/CodeSystem/v2-0360', code: 'MD' }], text: 'Doctor of Medicine' } }]
}];

router.get('/', (req, res) => {
  res.json({
    resourceType: 'Bundle',
    type: 'searchset',
    total: practitioners.length,
    entry: practitioners.map(p => ({ fullUrl: `${req.protocol}://${req.get('host')}/fhir/Practitioner/${p.id}`, resource: p }))
  });
});

router.get('/:id', (req, res) => {
  const practitioner = practitioners.find(p => p.id === req.params.id);
  if (!practitioner) return res.status(404).json({ resourceType: 'OperationOutcome', issue: [{ severity: 'error', code: 'not-found' }] });
  res.json(practitioner);
});

module.exports = router;
