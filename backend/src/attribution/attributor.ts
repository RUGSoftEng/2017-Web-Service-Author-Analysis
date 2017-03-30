/**
 * The Attributor is a wrapper around the GLAD system.
 *
 * The Attributor responds to Authorship verification requests.
 */

import * as child_process from 'child_process'; //require('child_process').execFile;
const execFile = child_process.execFile;
 
import { FromClientAttribution, ToClientAttribution } from './network_interface';

export class Attributor {
  constructor( ) { }
  
  // Callback that gets called once the Python program has finished
  // TODO: Wrap this with a task class
  private programFinishedCallback( callback: ( out: any ) => void, error, stdout, stderr ) {
    if ( error ) {
      callback( 'An error occurred' );
      return;
    }
    
    // Hackerish extraction of Python output
    // Clean this up after input/output rules are better established
    try {
      var arr = /.*((0|1)\.(\d*)).*((0|1)\.(\d*)).*/g.exec( stdout );
      let probability = parseFloat( arr[4] );
      
      let output: ToClientAttribution = {
        sameAuthorConfidence: probability
      };
      callback( output );
    } catch ( ex ) {
      callback( 'An error occurred' );
    }
  }
  
  public handleRequest( request: FromClientAttribution, callback: ( out: any ) => void ) {
    if ( !this.isValid_FromClient( request ) ) {
      callback( 'Invalid input' );
      return;
    }
    
    // NOTE: Only one known author text is used at the moment
    // Add multiple once GLAD input supports this
    const args = [ 'glad-copy.py',
                   '--inputknown', request.knownAuthorTexts[0],
                   '--inputunknown', request.unknownAuthorText,
                   '-m', 'models/default' ];
    const options = { cwd: 'resources/glad' };
    
    execFile( 'python3', args, options, this.programFinishedCallback.bind( this, callback ) );
  }
  
  /**
   * True if the request is a valid 'FromClientAttribution' interface
   */
  private isValid_FromClient( request: FromClientAttribution ): boolean {
    // TODO: More in-depth validity testing
    return ( request.knownAuthorTexts instanceof Array &&
             typeof request.unknownAuthorText === 'string' &&
             typeof request.language === 'string' &&
             typeof request.genre === 'number' &&
             typeof request.featureSet === 'number' );
  }
}
