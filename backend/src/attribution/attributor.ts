/**
 * The Attributor is a wrapper around the GLAD system.
 *
 * The Attributor responds to Authorship verification requests.
 */

import * as child_process from 'child_process'; //require('child_process').execFile;
import { BackendWrapper } from '../backend_wrapper';
const execFile = child_process.execFile;
 
import { FromClientAttribution, ToClientAttribution, FromClientAttribution_isValid } from './network_interface';

export class Attributor extends BackendWrapper<FromClientAttribution> {
  constructor( ) {
    super( FromClientAttribution_isValid );
  }
  
  // Callback that gets called once the Python program has finished
  // TODO: Wrap this with a task class
  private programFinishedCallback( callback: ( out: any ) => void, error, stdout, stderr ) {
    if ( error ) {
      console.log( error );
      callback( 'An error occurred' );
      return;
    }
    
    // GLAD outputs 2 lines.
    // Line 0 contains the JSON statistics
    // Line 1 contains the probability
    let lines: string[] = stdout.split( '\n' );
    
    // Hackerish extraction of probability
    // Clean this up after input/output rules are better established
    try {
      var arr = /.*((0|1)\.(\d*)).*((0|1)\.(\d*)).*/g.exec( lines[1] );
      let probability = parseFloat( arr[4] );
      
      let output: ToClientAttribution = {
        sameAuthorConfidence: probability,
        statistics: JSON.parse( lines[0] )
      };
      
      callback( output );
    } catch ( ex ) {
      callback( 'An error occurred' );
    }
  }
  
  private cleanInput( s: string ): string {
    return s.replace( '"', '\\"' )
            .replace( '\n', '\\n' )
            .replace( '\r', '\\r' )
  }
  
  // Override
  protected doHandleRequest( request: FromClientAttribution, callback: ( out: any ) => void ): void {
    // NOTE: Only one known author text is used at the moment
    // Add multiple once GLAD input supports this
    const args = [ 'glad-copy.py',
                   '--inputknown', this.cleanInput( request.knownAuthorTexts[0] ),
                   '--inputunknown', this.cleanInput( request.unknownAuthorText ),
                   '--combo', request.featureSet.toString(),
                   '-m', `models/model_${request.language}_${request.featureSet}` ];
    const options = { cwd: 'resources/glad' };
    
    execFile( 'python3', args, options, this.programFinishedCallback.bind( this, callback ) );
  }
}
