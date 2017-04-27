/**
 * The API for the Author Analysis Python program
 *
 * This API allows an external entity to communicate with the Author Analysis
 * systems through HTTP (e.g. our front-end). The API is, just like the system,
 * divided into the two appropriate systems:
 *  - Profiling   (dummy implemented)
 *  - Attribution
 *
 * Profiling involves determining the age and gender of the author of an unknown
 * text.
 * Attribution involves determining whether two texts are written by the same
 * author.
 */
import * as express from 'express';
import concat = require( 'concat-stream' ); // No ES6 @type for concat-stream available
import * as cors from 'cors';
import { BackendWrapper } from './backend_wrapper';
import { Profiler } from './profiling/profiler';
import { Attributor } from './attribution/attributor';

const app = express( );

app.use( setupApiBackendRouter( '/attribution', new Attributor( ) ) );
app.use( setupApiBackendRouter( '/profiling',   new Profiler( ) ) );

// For '/api', a plain-text 404 should be used, because '/api' resources are not
// appropriated for the front-end application. External entities communicating
// with this API will generally always use and expect plain-text.
app.all( '*', (req,res) => {
  res.status( 404 );
  res.contentType( 'text/plain' );
  res.send( '404 - Not found' );
} );

export { app as appApi };




/**
 * Sets up an Express router for a backend system
 */
function setupApiBackendRouter<T>( endpoint: string, backend: BackendWrapper<T> ) {
  const router = express.Router( );

  // Cross-Origin Resource Sharing should only be enabled during development
  // During development the front-end provider resides at another port, therefore
  // CORS is needed.
  router.use( endpoint, cors( {
    allowedHeaders: [ 'Origin', 'X-Requested-With', 'Content-Type', 'Accept' ]
  } ) );

  router.post( endpoint, (req,res,next) => {
    res.contentType( 'text/plain' );

    req.pipe( concat( (data) => {
      try {
        let request: T = JSON.parse( data.toString( 'utf8' ) );
        
        backend.handleRequest( request, ( out: any ): void => {
          res.send( JSON.stringify( out ) );
        } );
      } catch ( ex ) {
        // The retrieved input could not properly be parsed; Hence invalid input
        res.send( JSON.stringify( 'Invalid input' ) );
      }
    } ) );
  } );

  // Requests should be performed through a POST request with JSON content.
  // GET requests should not be made.
  router.get( endpoint, (req,res,next) => {
    res.contentType( 'text/plain' );
    res.send( 'Requests should be performed through a POST request' );
  } );
  
  return router;
}