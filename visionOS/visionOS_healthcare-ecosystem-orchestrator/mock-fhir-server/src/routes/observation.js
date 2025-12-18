const express = require('express');
const router = express.Router();
let observations = require('../data/observations.json');

router.get('/', (req, res) => {
  const { patient, category, code } = req.query;
  let filtered = [...observations];

  if (patient) filtered = filtered.filter(o => o.subject?.reference === `Patient/${patient}`);
  if (category) filtered = filtered.filter(o => o.category?.some(c => c.coding?.some(cd => cd.code === category)));
  if (code) filtered = filtered.filter(o => o.code?.coding?.some(c => c.code === code));

  res.json({
    resourceType: 'Bundle',
    type: 'searchset',
    total: filtered.length,
    entry: filtered.map(obs => ({
      fullUrl: `${req.protocol}://${req.get('host')}/fhir/Observation/${obs.id}`,
      resource: obs
    }))
  });
});

router.get('/:id', (req, res) => {
  const observation = observations.find(o => o.id === req.params.id);
  if (!observation) return res.status(404).json({ resourceType: 'OperationOutcome', issue: [{ severity: 'error', code: 'not-found' }] });
  res.json(observation);
});

router.post('/', (req, res) => {
  const newObs = { ...req.body, id: `obs-${Date.now()}`, meta: { lastUpdated: new Date().toISOString() } };
  observations.push(newObs);
  res.status(201).json(newObs);
});

module.exports = router;
