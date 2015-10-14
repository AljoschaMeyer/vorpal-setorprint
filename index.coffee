module.exports = (vorpal, options) ->
  defaultPrint = (arg) ->
    if vorpal.logger?
      vorpal.logger.info arg
    else
      vorpal.session.log arg

  defaultDescribe = (key) ->
    return "set or print #{key}"

  sop =
    options: options ? {}
    command: (key, obj, options = {}) ->
      vorpal.command "#{key} [#{key}]"
        .description options.description ? sop.options.describe key
        .action (args, cb) ->
          if args[key]?
            if options.validate?
              value = options.validate args[key]
            else
              value = args[key]
            obj[key] = value unless value is null
          else
            if options.print?
              options.print obj[key]
            else
              sop.options.print obj[key]
          cb()

  sop.options.print = defaultPrint unless sop.options.print?
  sop.options.describe = defaultDescribe unless sop.options.describe?

  vorpal.sop = sop
