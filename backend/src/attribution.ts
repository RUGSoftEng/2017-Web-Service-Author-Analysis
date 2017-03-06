const router = require( 'express' ).Router( );
const concat = require( 'concat-stream' );
import { FromClient, ToClient } from './attribution/network_interface';
import { Attributor } from './attribution/attributor';

const attributor = new Attributor( );

router.post( "/attribution", (req,res,next) => {

  // enable cross-origin resource sharing (CORS) 
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, content-type, Accept");

  req.pipe( concat( (data) => {

    
    let request: FromClient = JSON.parse( data.toString( 'utf8' ) );

    console.log(request);
    
    res.contentType( 'text/plain' );

    
    attributor.handleRequest( request, ( out: any ): void => {
      res.send( JSON.stringify( out ) );
    } );
    
  } ) );
} );

router.options( '/attribution', (req,res,next) => {
   // for CORS
   res.header("Access-Control-Allow-Origin", "*");
   res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
   res.send();
} );



router.get( '/attribution', (req,res,next) => {
  res.contentType( 'text/plain' );
  res.send( 'Requests should be performed through a POST request' );
} );

export { router as routerAttribution };
