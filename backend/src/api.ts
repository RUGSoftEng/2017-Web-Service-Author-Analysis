// Sub-app for the API used when communicating with the client

const express = require( 'express' );
import { routerAttribution } from './attribution';

const app = express( );

app.use( routerAttribution );

app.all( "*", (req,res) => {
  res.status( 404 );
  res.contentType( 'text/plain' );
  res.send( "404 - Not found" );
} );

export { app as appApi };