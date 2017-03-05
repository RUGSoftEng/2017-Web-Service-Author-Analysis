const express = require( 'express' );
const http = require( 'http' );
const path = require( 'path' );

import { appApi } from './src/api';

const app = express( );
const indexFile = 'index.html';

app.use( "/api", appApi );

app.use( express.static( 'public_html' ) );

// Any other resource not previously mentioned - 404
app.get( '*', ( req, res ) => {
  res.status( 404 );
  res.sendFile( path.join( __dirname, '/resources/404.html' ) );
} );

// Start using 'http'. Useful when we later want to use HTTPS
http.createServer( app ).listen( 8080, ( ) => {
  console.log( 'Running' );
} );