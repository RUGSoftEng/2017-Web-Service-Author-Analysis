/**
 * The API part for Authorship Profiling
 *
 * The API between the client endpoint, and the Profiling system.
 * The requester provides: (see 'network_interface.ts' for format)
 *  - A text
 *  - The language of the text
 *  - The genre of the texts (e-mail, tweet, novel, etc.)
 *  - Feature set
 * This API component invokes the Profiling system, and determines the gender
 * and age of the author. This response is sent back to the client.
 */
import * as express from 'express';
import concat = require( 'concat-stream' ); // No ES6 @type for concat-stream available
import * as cors from 'cors';

import { ToClientProfiling, FromClientProfiling } from './profiling/network_interface';
import { Profiler } from './profiling/profiler';

const router = express.Router( );
const profiler = new Profiler( );

// Cross-Origin Resource Sharing should only be enabled during development
// During development the front-end provider resides at another port, therefore
// CORS is needed.
router.use( '/profiling', cors( {
  allowedHeaders: [ 'Origin', 'X-Requested-With', 'Content-Type', 'Accept' ]
} ) );

router.post( '/profiling', (req,res,next) => {
  res.contentType( 'text/plain' );

  req.pipe( concat( (data) => {
    try {
      let request: FromClientProfiling = JSON.parse( data.toString( 'utf8' ) );
      
      profiler.handleRequest( request, ( out: any ): void => {
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
router.get( '/profiling', (req,res,next) => {
  res.contentType( 'text/plain' );
  res.send( 'Requests should be performed through a POST request' );
} );

export { router as routerProfiling };
