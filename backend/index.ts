/**
 * Author Analysis webserver.
 *
 * The Author Analysis webserver provides:
 *  - Static resources over HTTP (e.g. HTML files, images, etc.)
 *  - API for Author Analysis Python program 
 */
import * as express from 'express';
import * as http from 'http';
import * as path from 'path';

import { appApi } from './src/api';

const app = express( );

// Bind api to '/api'
app.use( '/api', appApi );

// Bind the 'public_html' directory to '/' for all remaining resources
app.use( express.static( 'public_html' ) );

// Any other resource not previously mentioned - 404
app.get( '*', ( req, res ) => {
  res.status( 404 );
  res.sendFile( path.join( __dirname, '/resources/404.html' ) );
} );

// Start server using 'http'. Useful when later HTTPS is used
http.createServer( app ).listen( 8080, ( ) => {
  console.log( 'Running' );
} );