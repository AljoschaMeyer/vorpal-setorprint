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
    addCommand: (obj, key, val) ->
      vorpal.command "#{key} [#{key}]"
        .description defaultDescribe key
        .action (args, cb) ->
          if args[key]?
            if val?
              value = val args[key]
            else
              value = args[key]
            obj[key] = value unless value is null
          else
            sop.options.print obj[key]
          cb()

  vorpal.sop = sop
