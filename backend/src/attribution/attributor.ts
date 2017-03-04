import { FromClient, ToClient } from './network_interface';

/**
 * Handles requests for Authorship Attribution
 */
export class Attributor {
  constructor( ) {
    
  }
  
  public handleRequest( request: FromClient, callback: ( out: any ) => void ) {
    if ( !this.isValid_FromClient( request ) ) {
      callback( 'Invalid input' );
      return;
    }
    
    let output: ToClient = {
      sameAuthor: true,
      confidence: 0.56
    };
    callback( output );
  }
  
  // Check if the request is a valid 'FromClient' interface
  private isValid_FromClient( request: FromClient ): boolean {
    return ( typeof request.knownAuthorText !== 'undefined' &&
             typeof request.unknownAuthorText !== 'undefined' );
  }
}