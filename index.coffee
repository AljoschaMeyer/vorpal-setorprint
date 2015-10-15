module.exports = (vorpal, options) ->
  defaultPrint = (arg) ->
    if vorpal.logger?
      vorpal.logger.info arg
    else
      vorpal.session.log arg

  defaultDescribe = (key) ->
    return "set or print #{key}"

  defaultFailedValidation = (key, arg) ->
    if vorpal.logger?
      vorpal.logger.error "#{arg} is an invalid value for #{key}"
    else
      vorpal.session.log "#{arg} is an invalid value for #{key}"

  defaultPassedValidation = (key, arg, value) ->
    if vorpal.logger?
      vorpal.logger.confirm "set #{key} to #{arg}"
    else
      vorpal.session.log "set #{key} to #{arg}"

  sop =
    options: options ? {}
    command: (key, obj, options = {}) ->
      return vorpal.command "#{key} [#{key}]"
        .description sop.options.describe key
        .action (args, cb) ->
          if args[key]?
            if options.validate?
              value = options.validate args[key]
            else
              value = args[key]
            if value is null
              if options.failedValidation?
                options.failedValidation key, args[key]
              else
                sop.options.failedValidation key, args[key]
            else
              obj[key] = value
              if options.passedValidation?
                options.passedValidation key, args[key], value
              else
                sop.options.passedValidation key, args[key], value
          else
            if options.print?
              options.print obj[key]
            else
              sop.options.print obj[key]
          cb()

  sop.options.print = defaultPrint unless sop.options.print?
  sop.options.describe = defaultDescribe unless sop.options.describe?
  sop.options.failedValidation = defaultFailedValidation unless sop.options.failedValidation?
  sop.options.passedValidation = defaultPassedValidation unless sop.options.passedValidation?

  vorpal.sop = sop
