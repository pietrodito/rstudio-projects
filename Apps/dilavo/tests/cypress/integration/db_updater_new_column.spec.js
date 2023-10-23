// tests/cypress/integration/db_updater_new_column.spec.js

const fs = require('fs');

describe("New column in table", () => {

  beforeEach(() => {
    cy.visit("#!/db_updater_file_upload")
  })

  it("'Browse' button exists", () => {
    cy.get(".btn-file").
      should('contain', 'Browse')
  });
  
  
  it("Upload key value csv", () => {
    cy.get('input[type=file]').selectFile('find.me')
  });
  
  
});

// file choose id 

