export default [
  {
    match: {

    },
    callback: {
      url: "http://resource/.mu/delta",
      method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 500,
      foldEffectiveChanges: true,
      ignoreFromSelf: true
    }
  },
  {
    match: {
      // listen to all changes
    },
    callback: {
      url: 'http://search/update',
      method: 'POST'
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true
    }
  },
  {
    match: {

    },
    callback: {
      url: "http://uuid-generation/delta",
      method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 250,
      foldEffectiveChanges: true,
      ignoreFromSelf: true
    }
  },
  {
    match: {
      predicate: { type: 'uri', value: 'http://purl.org/dc/terms/isVersionOf' }
    },
    callback: {
      url: "http://ldes-object/delta",
      method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 500,
      foldEffectiveChanges: true,
      ignoreFromSelf: true
    }
  }
];
