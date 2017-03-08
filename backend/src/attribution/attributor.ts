/**
 * The Attributor is a wrapper around the GLAD system.
 *
 * The Attributor responds to Authorship verification requests.
 *
 * IMPORTANT: Attributor is not currently linked with the GLAD system. Only
 * dummy output values are returned.
 */

import * as child_process from 'child_process'; //require('child_process').execFile;
const execFile = child_process.execFile;

 
import { FromClient, ToClient } from './network_interface';

export class Attributor {
  constructor( ) { }
  
  // Callback that gets called once the Python program has finished
  // TODO: Wrap this with a task class
  private programFinishedCallback( callback, error, stdout, stderr ) {
    if ( error ) {
      callback( 'An error occurred' );
      return;
    }
    
    // Hackerish extraction of Python output
    // Clean this up after input/output rules are better established
    try {
      var arr = /.*((0|1)\.(\d*)).*((0|1)\.(\d*)).*/g.exec( stdout );
      let probability = parseFloat( arr[4] );
      
      let output: ToClient = {
        sameAuthor: true,
        confidence: probability
      };
      callback( output );
    } catch ( ex ) {
      callback( 'An error occurred' );
    }
  }
  
  public handleRequest( request: FromClient, callback: ( out: any ) => void ) {
    if ( !this.isValid_FromClient( request ) ) {
      callback( 'Invalid input' );
      return;
    }
    
    const args = [ 'glad-copy.py',
                   '--inputknown', request.knownAuthorText,
                   '--inputunknown', request.unknownAuthorText,
                   '-m', 'models/default' ];
    const options = { cwd: 'resources/glad' };
    
    execFile( 'python3', args, options, this.programFinishedCallback.bind( this, callback ) );
  }
  
  /**
   * True if the request is a valid 'FromClient' interface
   */
  private isValid_FromClient( request: FromClient ): boolean {
    return ( typeof request.knownAuthorText !== 'undefined' &&
             typeof request.unknownAuthorText !== 'undefined' );
  }
}
