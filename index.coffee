module.exports = (vorpal, options) ->
  defaultPrint = (arg) ->
    if vorpal.logger?
      vorpal.logger.info arg
    else
      vorpal.session.log arg

  defaultDescribe = (key) ->
    return "set or print #{key}"

  sop =
    options: options ? {
      print: defaultPrint
      describe: defaultDescribe
    }
    addCommand: (obj, key) ->
      vorpal.command "#{key} [#{key}]"
        .description defaultDescribe key
        .action (args, cb) ->
          sop.options.print args[key]
          cb()

  vorpal.sop = sop
