/**
 * The Attributor is a wrapper around the GLAD system.
 *
 * The Attributor responds to Authorship verification requests.
 *
 * IMPORTANT: Attributor is not currently linked with the GLAD system. Only
 * dummy output values are returned.
 */
 
import { FromClient, ToClient } from './network_interface';

export class Attributor {
  constructor( ) { }
  
  public handleRequest( request: FromClient, callback: ( out: any ) => void ) {
    if ( !this.isValid_FromClient( request ) ) {
      callback( 'Invalid input' );
      return;
    }
    
    // Only dummy output is currently used.
    // TODO: Link Attributor with the GLAD system
    let output: ToClient = {
      sameAuthor: true,
      confidence: 0.56
    };
    callback( output );
  }
  
  /**
   * True if the request is a valid 'FromClient' interface
   */
  private isValid_FromClient( request: FromClient ): boolean {
    return ( typeof request.knownAuthorText !== 'undefined' &&
             typeof request.unknownAuthorText !== 'undefined' );
  }
}