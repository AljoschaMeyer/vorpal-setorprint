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
const sop = require('vorpal-setorprint');

vorpal.use(sop)
  .delimiter('vorpal-setorprint demo $')
  .show();

//TODO add stuff
```

### Usage

TODO 
