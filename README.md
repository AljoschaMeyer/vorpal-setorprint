# Vorpal - SetOrPrint

[![Build Status](https://travis-ci.org/AljoschaMeyer/vorpal-setorprint.svg)](https://travis-ci.org/AljoschaMeyer/vorpal-setorprint)

A [Vorpal.js](https://github.com/dthree/vorpal) extension for quickly creating commands which set a value, or print it if no argument was given.

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

sop.command(options, 'foo');
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

`command(obj, key [, val, print, description])`: Adds a command to vorpal which either sets or prints a specific value.

- `obj`, `key`: When the added command is called without arguments, obj[key] is printed to the user. When the command is called with an argument, obj[key] is set to this argument. `key` is also the name of the added command.
- `val`: an optional function to validate and parse the input. Receives args[key] and should return either the value for obj[key], or null, in which case obj[key] remains unchanged. You'll probably want to do some logging in this method to tell the user if validation failed.
- `print`: The function to be called when the added command is run without arguments. Defaults to `sop.options.print`.
- `description`: The description used in the help command. Defaults to `sop.options.describe(key)`

#### Options

The following options passed by `vorpal.use(vorpalSOP, options)` are used:

- `print`: a function to be called with the value to print if no argument was given a sop-command. The default function tries to use vorpal-log's `logger.info(arg)` and falls back to `vorpal.session.log(arg)`.
- `describe`: a function to be called with the key of each added command. The return value is used as the description for the help entry. Defaults to `return "set or print #{key}"`
