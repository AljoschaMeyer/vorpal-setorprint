module.exports = (vorpal, options) ->
  sop =
    options: options ? {}

  vorpal.sop = sop
