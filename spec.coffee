vorpalSOP = require './index'

Vorpal = require 'vorpal'
vorpalLog = require 'vorpal-log'

# Needed because too many vorpal emmiters are added otherwise
require('events').EventEmitter.defaultMaxListeners = Infinity

vorpal = null
sop = null

initVorpal = ->
  vorpal = null
  sop = null
  vorpal = Vorpal()
  vorpal.use vorpalSOP
  sop = vorpal.sop

describe 'The vorpal-log extension', ->
  beforeEach ->
    vorpal = null
    sop = null

  it 'adds a sop object to vorpal', ->
    vorpal = Vorpal()
    expect(vorpal.sop).not.toBeDefined()
    vorpal.use vorpalSOP
    expect(vorpal.sop).toBeDefined()
    expect(vorpal.sop).not.toBeNull()

  it 'saves options as sop.options', ->
    options = {foo: 'bar'}

    vorpal = Vorpal()
    vorpal.use vorpalSOP, options
    expect(vorpal.sop.options).toBe options
