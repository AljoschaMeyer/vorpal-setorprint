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
cmdOptions = null
customValidationResult = null

initVorpal = ->
  vorpal = null
  sop = null
  vorpal = Vorpal()
  vorpal.use vorpalSOP
  sop = vorpal.sop
  obj = {foo: 'bar'}

addExampleCommand = ->
  key = 'foo'
  sop.command key, obj
  cmd = vorpal.find key

addCommandWithOptions = ->
  key = 'foo'
  customValidationResult = 'öwalföwa'

  cmdOptions =
    validate: (arg) ->
      if arg is 'baz'
        return null
      else
        return customValidationResult
    print: (arg) ->
      return true
    description: 'a-öfmwaäipfgjaäw'
    passedValidation: (key, arg, value) ->
      return true
    failedValidation: (key, arg) ->
      return true

  sop.command key, obj, cmdOptions
  cmd = vorpal.find key

describe 'The vorpal-sop extension', ->
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

describe 'The command function', ->
  beforeEach ->
    initVorpal()

  it 'is exposed by the sop object', ->
    expect(sop.command).toBeDefined()
    expect(typeof sop.command).toBe 'function'

  it 'adds a command called [key] to vorpal', ->
    key = 'foo'
    expect(vorpal.find key).toBeUndefined()
    sop.command key, obj
    expect(vorpal.find key).not.toBeUndefined()

describe 'An added command', ->
  beforeEach ->
    initVorpal()
    addExampleCommand()

  it 'has a description based on sop.options.describe', ->
    spyOn(sop.options, 'describe').andCallThrough()
    expect(cmd.description()).toBe sop.options.describe key
    expect(sop.options.describe.calls.length).toBe 1
    expect(sop.options.describe.calls[0].args[0]).toBe key

  it 'calls sop.options.print with obj[key] if called without argument', ->
    spyOn sop.options, 'print'
    vorpal.exec "#{key}", (err, data) ->
      expect(sop.options.print.calls.length).toBe 1
      expect(sop.options.print.calls[0].args[0]).toBe obj[key]

  it 'sets obj.key to the argument if called with one', ->
    newValue = 'flkewjfö'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(obj[key]).toBe newValue

  it 'calls sop.options.passedValidation with key, arg, value (if validation passed)', ->
    spyOn sop.options, 'passedValidation'
    newValue = 'flkewjfö'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(sop.options.passedValidation.calls.length).toBe 1
      expect(sop.options.passedValidation.calls[0].args[0]).toBe key
      expect(sop.options.passedValidation.calls[0].args[1]).toBe newValue
      expect(sop.options.passedValidation.calls[0].args[2]).toBe newValue

describe 'A command with a validate function but without a validationFailed callback', ->
  beforeEach ->
    initVorpal()
    key = 'foo'

    cmdOptions =
      validate: (arg) ->
        return null

    sop.command key, obj, cmdOptions
    cmd = vorpal.find key

  it 'calls sop.options.failedValidation with key, arg (if validation failed)', ->
    spyOn sop.options, 'failedValidation'
    newValue = 'flkewjfö'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(sop.options.failedValidation.calls.length).toBe 1
      expect(sop.options.failedValidation.calls[0].args[0]).toBe key
      expect(sop.options.failedValidation.calls[0].args[1]).toBe newValue

describe 'A command added with a validation method', ->
  beforeEach ->
    initVorpal()
    addCommandWithOptions()

  it 'sets obj[key] to the result of val(args[key])', ->
    arg = 'öjföwifjäwf'
    vorpal.exec "#{key} #{arg}", (err, data) ->
      expect(obj[key]).toBe cmdOptions.validate(arg)

  it 'lets obj.key remain unchanged if val(args[key] is null)', ->
    expect(cmdOptions.validate 'baz').toBeNull()
    oldValue = obj[key]
    vorpal.exec "#{key} baz", (err, data) ->
      expect(obj[key]).toBe oldValue

describe 'A command added with a passedValidation method', ->
  beforeEach ->
    initVorpal()
    addCommandWithOptions()

  it 'calls this passedValidation method with key, arg, value (if validation actually passed)', ->
    spyOn sop.options, 'passedValidation'
    spyOn cmdOptions, 'passedValidation'
    newValue = 'flkewjfö'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(sop.options.passedValidation.calls.length).toBe 0
      expect(cmdOptions.passedValidation.calls.length).toBe 1
      expect(cmdOptions.passedValidation.calls[0].args[0]).toBe key
      expect(cmdOptions.passedValidation.calls[0].args[1]).toBe newValue
      expect(cmdOptions.passedValidation.calls[0].args[2]).toBe customValidationResult

describe 'A command added with a failedValidation method', ->
  beforeEach ->
    initVorpal()
    addCommandWithOptions()

  it 'calls this failedValidation method with key, arg (if validation actually passed)', ->
    spyOn sop.options, 'failedValidation'
    spyOn cmdOptions, 'failedValidation'
    newValue = 'baz'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(sop.options.failedValidation.calls.length).toBe 0
      expect(cmdOptions.failedValidation.calls.length).toBe 1
      expect(cmdOptions.failedValidation.calls[0].args[0]).toBe key
      expect(cmdOptions.failedValidation.calls[0].args[1]).toBe newValue

describe 'A command added with a print method', ->
  beforeEach ->
    initVorpal()
    addCommandWithOptions()

  it 'calls this print method with obj[key] if called without argument, instead of the global default print', ->
    spyOn sop.options, 'print'
    spyOn cmdOptions, 'print'
    vorpal.exec "#{key}", (err, data) ->
      expect(sop.options.print.calls.length).toBe 0
      expect(cmdOptions.print.calls.length).toBe 1
      expect(cmdOptions.print.calls[0].args[0]).toBe obj[key]

describe 'A command added with a description', ->
  beforeEach ->
    initVorpal()
    addCommandWithOptions()

  it 'sets the description to the given one instead of options.describe(key)', ->
    expect(cmd.description()).toBe cmdOptions.description

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

describe 'The default failedValidation method', ->
  key = 'foo'
  arg = 'qux'
  expectedMsg = "#{arg} is an invalid value for #{key}"

  beforeEach ->
    initVorpal()
    addExampleCommand()

  it 'exists', ->
    expect(sop.options.failedValidation).toBeDefined()
    expect(typeof sop.options.failedValidation).toBe 'function'

  it 'uses vorpal.instance.print without vorpal-log', ->
    spyOn vorpal.session, 'log'
    # make sure the default behavior is used
    expect(vorpal.logger).toBeUndefined()
    sop.options.failedValidation key, arg
    expect(vorpal.session.log.calls.length).toBe 1
    expect(vorpal.session.log.calls[0].args[0]).toBe expectedMsg

  it 'uses vorpal.logger methods if available', ->
    vorpal.use vorpalLog
    expect(vorpal.logger).toBeDefined()

    spyOn vorpal.logger, 'error'

    sop.options.failedValidation key, arg
    expect(vorpal.logger.error.calls.length).toBe 1
    expect(vorpal.logger.error.calls[0].args[0]).toBe expectedMsg

describe 'The default passedValidation method', ->
  key = 'foo'
  arg = 'qux'
  value = 'qux'
  expectedMsg = "set #{key} to #{arg}"

  beforeEach ->
    initVorpal()
    addExampleCommand()

  it 'exists', ->
    expect(sop.options.passedValidation).toBeDefined()
    expect(typeof sop.options.failedValidation).toBe 'function'

  it 'uses vorpal.instance.print without vorpal-log', ->
    spyOn vorpal.session, 'log'
    # make sure the default behavior is used
    expect(vorpal.logger).toBeUndefined()
    sop.options.passedValidation key, arg, value
    expect(vorpal.session.log.calls.length).toBe 1
    expect(vorpal.session.log.calls[0].args[0]).toBe expectedMsg

  it 'uses vorpal.logger methods if available', ->
    vorpal.use vorpalLog
    expect(vorpal.logger).toBeDefined()

    spyOn vorpal.logger, 'confirm'

    sop.options.passedValidation key, arg
    expect(vorpal.logger.confirm.calls.length).toBe 1
    expect(vorpal.logger.confirm.calls[0].args[0]).toBe expectedMsg
