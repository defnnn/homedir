it('visits /', () => {
  cy.visit('/').get('a').each(($el, index, $list) => {
    cy.wrap($el).and('have.attr', 'href')
  })
})
