const router = require( 'express' ).Router( );
const concat = require( 'concat-stream' );
import { FromClient, ToClient } from './attribution/network_interface';
import { Attributor } from './attribution/attributor';

const attributor = new Attributor( );

router.post( "/attribution", (req,res,next) => {
  req.pipe( concat( (data) => {
    
    let request: FromClient = JSON.parse( data.toString( 'utf8' ) );
    
    res.contentType( 'text/plain' );
    
    attributor.handleRequest( request, ( out: any ): void => {
      res.send( JSON.stringify( out ) );
    } );
    
  } ) );
} );

router.get( '/attribution', (req,res,next) => {
  res.contentType( 'text/plain' );
  res.send( 'Requests should be performed through a POST request' );
} );

export { router as routerAttribution };