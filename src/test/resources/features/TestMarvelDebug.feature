Feature: Marvel Characters API Test - Debugging

  Background:
    * url 'http://localhost:8080/glocarri/api'

  Scenario: Debug - Simple POST test
    Given path '/characters'
    And request 
    """
    {
      "name": "Debug Hero",
      "alterego": "Debug Alter",
      "description": "Debug description",
      "powers": ["Debug"]
    }
    """
    When method POST
    Then status 201
    And print 'POST Response:', response
    * def createdId = response.id
    
    # Clean up
    Given path '/characters/' + createdId
    When method DELETE
    Then status 204
