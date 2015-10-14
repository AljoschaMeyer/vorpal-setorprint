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
  sop.command obj, key
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

describe 'The command function', ->
  beforeEach ->
    initVorpal()

  it 'is exposed by the sop object', ->
    expect(sop.command).toBeDefined()
    expect(typeof sop.command).toBe 'function'

  it 'adds a command called [key] to vorpal', ->
    key = 'foo'
    expect(vorpal.find key).toBeUndefined()
    sop.command obj, key
    expect(vorpal.find key).not.toBeUndefined()

describe 'An added command', ->
  beforeEach ->
    initVorpal()
    addExampleCommand()

  it 'has a description based on sop.options.describe', ->
    expect(cmd.description()).toBe sop.options.describe key

  it 'calls sop.options.print with obj.key if called without argument', ->
    spyOn sop.options, 'print'
    vorpal.exec "#{key}", (err, data) ->
      expect(sop.options.print.calls.length).toBe 1
      expect(sop.options.print.calls[0].args[0]).toBe obj[key]

  it 'sets obj.key to the argument if called with one', ->
    newValue = 'flkewjfö'
    vorpal.exec "#{key} #{newValue}", (err, data) ->
      expect(obj[key]).toBe newValue

describe 'A commands added with a val method', ->
  val = (arg) ->
    if arg is 'baz'
      return null
    else
      return 'qux'

  beforeEach ->
    initVorpal()
    key = 'foo'
    sop.command obj, key, val
    cmd = vorpal.find key

  it 'sets obj.key to the result of val(args[key])', ->
    arg = 'öjföwifjäwf'
    vorpal.exec "#{key} #{arg}", (err, data) ->
      expect(obj[key]).toBe val(arg)

  it 'lets obj.key remain unchanged if val(args[key] is null)', ->
    expect(val 'baz').toBeNull()
    oldValue = obj[key]
    vorpal.exec "#{key} baz", (err, data) ->
      expect(obj[key]).toBe oldValue

describe 'A commands added with a print method', ->
  printcalls = null
  print = (arg) ->
    printcalls++

  beforeEach ->
    initVorpal()
    key = 'foo'
    sop.command obj, key, null, print
    cmd = vorpal.find key
    printcalls = 0

  it 'calls print with obj.key if called without argument, instead of options.print', ->
    spyOn sop.options, 'print'
    vorpal.exec "#{key}", (err, data) ->
      expect(sop.options.print.calls.length).toBe 0
      expect(printcalls).toBe 1

describe 'A command added with a description', ->
  forcedDescription = 'a-öfmwaäipfgjaäw'

  beforeEach ->
    initVorpal()
    key = 'foo'
    sop.command obj, key, null, null, forcedDescription
    cmd = vorpal.find key

  it 'sets the description to the given one instead of options.describe(key)', ->
    expect(cmd.description()).toBe forcedDescription

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
