# Vorpal - SetOrPrint

[![Build Status](https://travis-ci.org/AljoschaMeyer/vorpal-setorprint.svg)](https://travis-ci.org/AljoschaMeyer/vorpal-setorprint)

A [Vorpal.js](https://github.com/dthree/vorpal) extension for quickly creating commands which set a value, or print it if no argument was given. Think instant getters/setters for the console.

### Installation

```bash
npm install vorpal-setorprint
npm install vorpal
```

### Getting Started

```js
const vorpal = (require('vorpal'))();
const vorpalSOP = require('vorpal-setorprint');

vorpal.use(vorpalSOP)
  .delimiter('vorpal-setorprint demo $')
  .show();

const sop = vorpal.sop;
const options = {foo: 'bar'};

sop.command('foo', options);
```

```
$ node ./myapp.js
vorpal-setorprint demo $ help foo

Usage: foo [options] [foo]


set or print foo

Options:

  --help  output usage information

vorpal-setorprint demo $ foo
bar
vorpal-setorprint demo $ foo qux
vorpal-setorprint demo $ foo
qux
vorpal-setorprint demo $
```

### Usage

Adds a `sop` object to vorpal, which stores `options` and provides a `command` function.

`command(key, obj[, options])`: Adds a command to vorpal which either sets or prints a specific value. Returns the `command` object, just like `vorpal.command` does. This allows convenient chaining, e.g.

```js
sop.command(key, obj)
  .alias('foobar')
  .description('I like trains.');
```

- `obj`, `key`: When the added command is called without arguments, `obj[key]` is printed to the user. When the command is called with an argument, `obj[key]` is set to this argument. `key` is also the name of the added command.
- `options`: The following values of the option object are used:
  - `validate`: an optional function to validate and parse the input. Receives `args[key]` and should return either the value for `obj[key]`, or null, in which case `obj[key]` remains unchanged.
  - `print`: The function to be called when the added command is run without arguments. Defaults to `sop.options.print`.
  - `failedValidation`: A function which is called when `validate` returns null. Defaults to `sop.options.failedValidation`.
  - `passedValidation`: A function which is called when `validate` does not return null. Defaults to `sop.options.passedValidation`.

See [the example](https://github.com/AljoschaMeyer/vorpal-log/tree/master/examples) here for a simple usage of all the options.

#### Options

The following options passed by `vorpal.use(vorpalSOP, options)` are used:

- `print`: a function to be called with the value to print if no argument was given a sop-command. The default function tries to use [vorpal-log](https://github.com/AljoschaMeyer/vorpal-log)'s `logger.info(arg)` and falls back to `vorpal.session.log(arg)`.
- `describe`: a function to be called with the key of each added command. The return value is used as the description for the help entry. Defaults to `return "set or print #{key}"`. This value can simply be overridden by calling vorpal's `description` method on the command object returned by `sop.command`.
- `failedValidation`: a function to be called with `key`, `arg` when an input fails to pass validation. `arg` is the argument as parsed by vorpal. By default, this prints `"#{arg} is an invalid value for #{key}"`.
- `passedValidation`: a function to be called with `key`, `arg` and `value` when an input passes validation. `arg` is the argument as parsed by vorpal, `value` is what the `validate` function returned. By default, this prints `"set #{key} to #{arg}"`.
