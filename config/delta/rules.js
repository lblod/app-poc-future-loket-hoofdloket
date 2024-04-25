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
      ignoreFromSelf: true
    }
  }
];
