# Author Analysis Webserver

## Getting Started
The webserver is written in TypeScript, and can be run with the Node configuration explained below.
It contains a HTTP server. This server can serve static HTTP content (e.g. HTML files, images, etc.).
This server will also handle requests for non-static content. (E.g. AJAX requests)

### Prerequisites

* [Node.js](https://nodejs.org/) (v6.10.0) - Node.js runs all webserver code

### Setup
Instructions on how to set up a development environment.

* Clone this repository
* In terminal, from the directory of the repository, run: `npm install`
  This installs all node dependencies (in `node_modules`)

### Running the webserver
In terminal, in the `backend` folder, run one of the following:

* `npm run build:windows` - If you are using Microsoft Windows
* `npm run build:linux` - If you are using a *nix based system

This starts the webserver (on port 8080), and will restart the webserver whenever a change is made.
The web application can be accessed by going to [http://localhost/](http://localhost/).

## Directory structure

* `src` - Contains the TypeScript source code for the webserver
* `public_html` - Contains static resources (These are accessible for anyone visiting the website)
* `resources` - Resources for the Webserver (These are not directly accessible to website visitors)

### Other directories
Other directories can be generated through the provided script. Do **NOT** upload these into the repository.

* `node_modules` - Contain installed modules for Node.js
