// tests/cypress/integration/db_updater_file_upload.spec.js

describe("File uploader", () => {

  beforeEach(() => {
    cy.visit("#!/db_updater_file_upload")
  })

  it("'Browse' button exists", () => {
    cy.get(".btn-file").
      should('contain', 'Browse')
  });
});

// file choose id #app-db_updater_file_upload-upload

