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

sop.addCommand values, 'greeting'

validateName = (arg) ->
  if arg.match(/\d/) is null
    logger.confirm 'What a splendid name!'
    return arg
  else
    logger.error 'Real names don\'t contain digits! Chose another one.'
    return null

print = (arg) ->
  logger.info "Your name seems to be #{arg}, am I right?"

sop.addCommand values, 'name', validateName, print, 'Not only has this command a cusomized description, no, it also sets or prints the name'

vorpal.command 'greet'
  .description 'a complex command to greet the user'
  .action (args, cb) ->
    logger.log "#{values.greeting}, #{values.name}."
    cb()

logger.printMsg ''
logger.info 'This is a demo program for the vorpal-log extension.'
logger.info 'Run help to see what vorpal-setorprint added'
