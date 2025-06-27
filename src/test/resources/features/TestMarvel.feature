@glocarri @prueba_marvel
Feature: Prueba de Automatizacion API REST para gestión de personajes de Marvel


  Background:
    * url 'http://localhost:8080/glocarri/api'
    * def baseUrl = 'http://localhost:8080/glocarri/api/characters'
    * def validCharacter = read('classpath:data/request_create_character.json')
    * def invalidCharacter = read('classpath:data/request_create_invalid_character.json')
    * def updateCharacter = read('classpath:data/request_update_character.json')
    * def characterId = null

  # ============================
  # PRUEBAS POST - CREAR PERSONAJE
  # ============================
  @id:1 @crearPersonaje @solicitudExitosa201  
  Scenario: POST - Crear personaje exitosamente
    Given path '/characters'
    And request validCharacter
    When method POST
    Then status 201
    And match response.id == '#number'
    And match response.name == validCharacter.name
    And match response.alterego == validCharacter.alterego
    And match response.description == validCharacter.description
    And match response.powers == validCharacter.powers
    * def characterId = response.id
    * karate.set('global', { createdCharacterId: characterId })
  @id:2 @crearPersonaje @errorValidacion400  
  Scenario: POST - Crear personaje con campos requeridos faltantes
    Given path '/characters'
    And request invalidCharacter
    When method POST
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'
  @id:3 @crearPersonaje @errorDuplicado400  
  Scenario: POST - Crear personaje con nombre duplicado
    * def jsonData = read('classpath:data/request_create_character.json')
        And request jsonData
        When method POST
        Then status 400

  # ============================
  # PRUEBAS GET - OBTENER PERSONAJES
  # ============================
  @id:4 @obtenerPersonajes @solicitudExitosa200
  Scenario: GET - Obtener todos los personajes
    Given path '/characters'
    When method GET
    Then status 200
    And match response != null
  @id:5 @obtenerPersonajePorId @solicitudExitosa200 
  Scenario: GET - Obtener personaje por ID existente
    # Primero creamos un personaje para poder obtenerlo
    Given path '/characters'
    And request validCharacter
    When method POST
    Then status 201
    * def createdId = response.id

    # Ahora lo obtenemos por ID
    Given path '/characters/' + createdId
    When method GET
    Then status 200
    And match response.id == createdId
    And match response.name == validCharacter.name
    And match response.alterego == validCharacter.alterego
    And match response.description == validCharacter.description
    And match response.powers == validCharacter.powers

    # Limpiamos el personaje creado
    Given path '/characters/' + createdId
    When method DELETE
    Then status 204
  @id:6 @obtenerPersonajePorId @errorNoEncontrado404  
  Scenario: GET - Obtener personaje por ID no existente
    Given path '/characters/999'
    When method GET
    Then status 404
    And match response.error == 'Character not found'
  @id:7 @verificarPersonaje @solicitudExitosa200  
  Scenario: GET - Verificar lista de personajes después de crear uno
    # Obtenemos el número inicial de personajes
    Given path '/characters'
    When method GET
    Then status 200
    * def initialCount = response.length

    # Creamos un personaje
    Given path '/characters'
    And request validCharacter
    When method POST
    Then status 201
    * def createdId = response.id

    # Verificamos que aparece en la lista
    Given path '/characters'
    When method GET
    Then status 200
    And match response.length == initialCount + 1
    And match response[*].id contains createdId

    # Limpiamos el personaje creado
    Given path '/characters/' + createdId
    When method DELETE
    Then status 204

  # ============================
  # PRUEBAS PUT - ACTUALIZAR PERSONAJE
  # ============================
  @id:8 @actualizarPersonaje @solicitudExitosa200
  Scenario: PUT - Actualizar personaje exitosamente
    Given path '/characters/' + id
    * def updateData = read('classpath:data/marvel/request_update_character.json')
    And request updateData
    When method PUT
    Then status 200
    And match response != null
    And match response.description == updateData.description

  @id:9 @actualizarPersonaje @errorNoEncontrado404  
  Scenario: PUT - Actualizar personaje no existente
    Given path '/characters/999'
    And request updateCharacter
    When method PUT
    Then status 404
    And match response.error == 'Character not found'

  @id:10 @actualizarPersonaje @errorValidacion400
  Scenario: PUT - Actualizar personaje con datos inválidos
    # Primero creamos un personaje
    Given path '/characters'
    And request validCharacter
    When method POST
    Then status 201
    * def createdId = response.id

    # Intentamos actualizarlo con datos inválidos
    Given path '/characters/' + createdId
    And request invalidCharacter
    When method PUT
    Then status 400

    # Limpiamos el personaje creado
    Given path '/characters/' + createdId
    When method DELETE
    Then status 204

  # ============================
  # PRUEBAS DELETE - ELIMINAR PERSONAJE
  # ============================
  @id:11 @eliminarPersonaje @solicitudExitosa204
  Scenario: DELETE - Eliminar personaje exitosamente
    # Primero creamos un personaje
    Given path '/characters'
    And request validCharacter
    When method POST
    Then status 201
    * def createdId = response.id

    # Verificamos que existe
    Given path '/characters/' + createdId
    When method GET
    Then status 200

    # Lo eliminamos
    Given path '/characters/' + createdId
    When method DELETE
    Then status 204

    # Verificamos que ya no existe
    Given path '/characters/' + createdId
    When method GET
    Then status 404

  @id:12 @eliminarPersonaje @errorNoEncontrado404
  Scenario: DELETE - Eliminar personaje no existente
    Given path '/characters/999'
    When method DELETE
    Then status 404
    And match response.error == 'Character not found'

  @id:13 @eliminarPersonaje @solicitudExitosa204
  Scenario: DELETE - Verificar eliminación de múltiples personajes
    # Obtenemos el conteo inicial
    Given path '/characters'
    When method GET
    Then status 200
    * def initialCount = response.length

    # Creamos algunos personajes
    Given path '/characters'
    And request validCharacter
    When method POST
    Then status 201
    * def firstId = response.id

    Given path '/characters'
    And request 
    """
    {
      "name": "Spider-Man",
      "alterego": "Peter Parker",
      "description": "Friendly neighborhood spider",
      "powers": ["Web", "Strength"]
    }
    """
    When method POST
    Then status 201
    * def secondId = response.id

    # Verificamos que hay 2 personajes más
    Given path '/characters'
    When method GET
    Then status 200
    And match response.length == initialCount + 2

    # Eliminamos ambos
    Given path '/characters/' + firstId
    When method DELETE
    Then status 204

    Given path '/characters/' + secondId
    When method DELETE
    Then status 204

    # Verificamos que regresamos al conteo inicial
    Given path '/characters'
    When method GET
    Then status 200
    And match response.length == initialCount