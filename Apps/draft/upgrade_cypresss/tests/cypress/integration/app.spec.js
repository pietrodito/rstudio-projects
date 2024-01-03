describe('app', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('starts', () => {})

  it('hello text appears', () => {
    cy.get("h3.title").should("contain", "Hello")
    cy.get("#app-header").should("contain", "Hello")
  })
})