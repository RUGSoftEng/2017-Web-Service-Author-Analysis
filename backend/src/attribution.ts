/**
 * The API part for Authorship Attribution
 *
 * The API between the client endpoint, and the GLAD Authorship Attribution
 * system.
 * The requester provides two texts (see 'network_interface.ts' for format):
 *  - A text of known author
 *  - A text of unknown author
 * This API component invokes the GLAD system, which determines whether the two
 * texts are written by the same author. This response is sent back to the
 * client endpoint.
 */
import * as express from 'express';
import concat = require( 'concat-stream' ); // No ES6 @type for concat-stream available
import * as cors from 'cors';

import { FromClient, ToClient } from './attribution/network_interface';
import { Attributor } from './attribution/attributor';

const router = express.Router( );
const attributor = new Attributor( );

// Cross-Origin Resource Sharing should only be enabled during development
// During development the front-end provider resides at another port, therefore
// CORS is needed.
router.use( '/attribution', cors( {
  allowedHeaders: [ 'Origin', 'X-Requested-With', 'Content-Type', 'Accept' ]
} ) );

router.post( '/attribution', (req,res,next) => {
  res.contentType( 'text/plain' );

  req.pipe( concat( (data) => {
    try {
      let request: FromClient = JSON.parse( data.toString( 'utf8' ) );
      
      attributor.handleRequest( request, ( out: any ): void => {
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
router.get( '/attribution', (req,res,next) => {
  res.contentType( 'text/plain' );
  res.send( 'Requests should be performed through a POST request' );
} );

export { router as routerAttribution };
