# Author Analysis Webserver

## Getting Started
The webserver is written in TypeScript, and can be run with the Node configuration explained below.
It contains a HTTP server. This server can serve static HTTP content (e.g. HTML files, images, etc.).
This server will also handle requests for non-static content. (E.g. AJAX requests)

### Prerequisites

* [Node.js](https://nodejs.org/) (v6.10.0) - Node.js runs all webserver code
* [GLAD](https://github.com/sixhobbits/rug-authorship-web#installation)

### Setup Node & Npm
Instructions on how to set up a development environment.

* Clone this repository
* In terminal, from the directory of the repository, run: `npm install`
  This installs all node dependencies (in `node_modules`)

### Setup GLAD

* Install the `glad` directory in the `backend/resources` directory (So it becomes `backend/resources/glad`). 
    Installation instructions for GLAD are [here](https://github.com/sixhobbits/rug-authorship-web#installation). 
    You can either rename the directory rug-authorship-web to glad, or create a symbolic link to the same effect.
* Now you should have a `glad-copy.py` file in the `backend/resources/glad` directory.
  
### Running the webserver
On some systems it is necessary to activate the GLAD Anaconda environment before running the webserver.
Note that this environment was previously created during GLAD setup. This environment can be activated using:

* `activate glad` - If you are using Microsoft Windows
* `source activate glad` - If you are using a *nix based system

In terminal, in the `backend` folder, run one of the following:

* `npm run build:windows` - If you are using Microsoft Windows
* `npm run build:linux` - If you are using a *nix based system

This starts the webserver (on port 8080), and will restart the webserver whenever a change is made.
The web application can be accessed by going to [http://localhost:8080/](http://localhost:8080/).

## Directory structure

* `src` - Contains the TypeScript source code for the webserver
* `public_html` - Contains static resources (These are accessible for anyone visiting the website)
* `resources` - Resources for the Webserver (These are not directly accessible to website visitors)

### Other directories
Other directories can be generated through the provided script. Do **NOT** upload these into the repository.

* `node_modules` - Contain installed modules for Node.js

## Testing
For testing, the `mocha` framework is used. Install `mocha` globally using:
```bash
npm install -g mocha
```
Then run tests in the terminal, while inside the `backend` directory, using:
```
npm test
```
Note that this explicitely transpiles all TypeScript files into JavaScript files (`*.js`), because mocha does not natively/internally support TypeScript. These JavaScript files are not deleted by the script itself after completion, to avoid erronous deletion. However, these JavaScript files serve no purpose, and can safely be deleted.
