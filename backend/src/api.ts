/**
 * The API for the Author Analysis Python program
 *
 * This API allows an external entity to communicate with the Author Analysis
 * systems through HTTP (e.g. our front-end). The API is, just like the system,
 * divided into the two appropriate systems:
 *  - Profiling   (not yet implemented)
 *  - Attribution (dummy implemented)
 *
 * Profiling involves determining the age and gender of the author of an unknown
 * text.
 * Attribution involves determining whether two texts are written by the same
 * author.
 */
import * as express from 'express';
import { routerAttribution } from './attribution';

const app = express( );

app.use( routerAttribution );

// For '/api', a plain-text 404 should be used, because '/api' resources are not
// appropriated for the front-end application. External entities communicating
// with this API will generally always use and expect plain-text.
app.all( '*', (req,res) => {
  res.status( 404 );
  res.contentType( 'text/plain' );
  res.send( '404 - Not found' );
} );

export { app as appApi };