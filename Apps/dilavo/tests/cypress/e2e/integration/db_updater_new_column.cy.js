// tests/cypress/integration/db_updater_new_column.spec.js

const fs = require('fs');

beforeEach(() => {
  cy.visit("#!/cy_db_updater_new_column")
})

describe("Columns in table", () => {

  const a_cols = 'champ statut annee periode date du resultat ipe cret3 count '
  const b_cols = 'percent pctcum effcum per_comp finess_comp date_comp temp_comp'
  const old_cols = a_cols + b_cols
  const new_col = 'flag_export_finess'
  const new_cols = old_cols + ' ' + new_col 

  it("Test tables first upload", () => {
    cy.get("#app-cy_db_updater_new_column-reset").click()
    cy.get("#app-cy_db_updater_new_column-up1").click()
    cy.get('.shiny-notification-close').click()
    cy.get("#app-cy_db_updater_new_column-list").click()
    cy.get("#app-cy_db_updater_new_column-out").
      should('contain', 't1q2chcr_2 t1q2chcr_3')
  });

  it("Test column first upload", () => {

    cy.get("#app-cy_db_updater_new_column-cols").click()
    cy.get("#app-cy_db_updater_new_column-out").
      should('contain', old_cols)
    cy.get("#app-cy_db_updater_new_column-out").
      should('not.include.text', new_col)
  });

  it("Test table upload with new column", () => {

    cy.get(".shiny-notification-close").click()
    cy.get("#app-cy_db_updater_new_column-up2").click()
    cy.get('.shiny-notification-close').click()
    cy.get("#app-cy_db_updater_new_column-cols").click()
    cy.get("#app-cy_db_updater_new_column-out").
      should('contain', new_cols)
  });
  
  it("Test table upload with missing column", () => {

    cy.get(".shiny-notification-close").click()
    cy.get("#app-cy_db_updater_new_column-up1").click()
    cy.get('.shiny-notification-close').click()
    cy.get("#app-cy_db_updater_new_column-cols").click()
    cy.get("#app-cy_db_updater_new_column-out").
      should('contain', new_cols)
  });
});