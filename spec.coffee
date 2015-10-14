vorpalSOP = require './index'

Vorpal = require 'vorpal'
vorpalLog = require 'vorpal-log'

# Needed because too many vorpal emmiters are added otherwise
require('events').EventEmitter.defaultMaxListeners = Infinity

vorpal = null
sop = null
obj = null
key = null
cmd = null

initVorpal = ->
  vorpal = null
  sop = null
  vorpal = Vorpal()
  vorpal.use vorpalSOP
  sop = vorpal.sop
  obj = {foo: 'bar'}

addExampleCommand = ->
  key = 'foo'
  sop.addCommand obj, key
  cmd = vorpal.find key

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

describe 'The addCommand function', ->
  beforeEach ->
    initVorpal()

  it 'is exposed by the sop object', ->
    expect(sop.addCommand).toBeDefined()
    expect(typeof sop.addCommand).toBe 'function'

  it 'adds a command called [key] to vorpal', ->
    key = 'foo'
    expect(vorpal.find key).toBeUndefined()
    sop.addCommand obj, key
    expect(vorpal.find key).not.toBeUndefined()

describe 'An added command', ->
  beforeEach ->
    initVorpal()
    addExampleCommand()

  it 'has a description based on sop.options.describe', ->
    expect(vorpal.find(key).description()).toBe sop.options.describe key

  it 'calls sop.options.print with obj.key if called without argument', ->
    spyOn sop.options, 'print'
    vorpal.exec "#{key}", (err, data) ->
      expect(sop.options.print.calls.length).toBe 1
      expect(sop.options.print.calls[0].args[0]).toBe obj[key]

  it 'sets obj.key to the argument if called with one', ->
    newValue = 'flkewjfö'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(obj[key]).toBe newValue

describe 'The default describe method', ->
  beforeEach ->
    initVorpal()
    addExampleCommand()

  it 'exists', ->
    expect(sop.options.describe).toBeDefined()
    expect(typeof sop.options.describe).toBe 'function'

  it 'returns "set or print #{key}"', ->
    expect(sop.options.describe key).toBe "set or print #{key}"

describe 'The default print method', ->
  msg = null

  beforeEach ->
    initVorpal()
    addExampleCommand()
    msg = 'foo'

  it 'exists', ->
    expect(sop.options.print).toBeDefined()
    expect(typeof sop.options.print).toBe 'function'

  it 'delegates to vorpal.instance.print without vorpal-log', ->
    spyOn vorpal.session, 'log'
    # make sure the default behavior is used
    expect(vorpal.logger).toBeUndefined()
    sop.options.print msg
    expect(vorpal.session.log.calls.length).toBe 1
    expect(vorpal.session.log.calls[0].args[0]).toBe msg

  it 'uses vorpal.logger methods if available', ->
    vorpal.use vorpalLog
    expect(vorpal.logger).toBeDefined()

    spyOn vorpal.logger, 'info'

    sop.options.print msg
    expect(vorpal.logger.info.calls.length).toBe 1
    expect(vorpal.logger.info.calls[0].args[0]).toBe msg
