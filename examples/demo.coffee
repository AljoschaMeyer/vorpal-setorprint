vorpal = (require 'vorpal')()
vorpalLog = require 'vorpal-log'
vorpalSOP = require '../index'

vorpal.use vorpalLog
  .use vorpalSOP
  .delimiter 'vorpal-setorprint demo $'
  .show()

logger = vorpal.logger
sop = vorpal.sop

values =
  greeting: 'Hello'
  name: 'Franz Foobert'

sop.command 'greeting', values
  .alias 'foobar'

validateName = (arg) ->
  if arg.match(/\d/) is null
    return arg
  else
    return null

printName = (arg) ->
  logger.info "Your name seems to be #{arg}, am I right?"

failedValidationName = (key, arg) ->
  logger.error "A real #{key} doesn\'t contain digits! I bet #{arg} isn\'t even your real name."

passedValidationName = (key, arg, value) ->
  logger.confirm "#{value}? Well, that\'s a splendid #{key}."

nameOptions =
  validate: validateName
  print: printName
  failedValidation: failedValidationName
  passedValidation: passedValidationName

sop.command 'name', values, nameOptions
  .description 'prints or sets the name, with a custom description'

vorpal.command 'greet'
  .description 'a complex command to greet the user'
  .action (args, cb) ->
    logger.log "#{values.greeting}, #{values.name}."
    cb()

logger.printMsg ''
logger.info 'This is a demo program for the vorpal-log extension.'
logger.info 'Run help to see what vorpal-setorprint added'
