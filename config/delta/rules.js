export default [
  {
    match: {
      predicate: { type: 'uri', value: 'http://purl.org/dc/terms/isVersionOf' }
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
