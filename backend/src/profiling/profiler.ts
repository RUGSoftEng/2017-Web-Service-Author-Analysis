/**
 * The Profiler is a wrapper around the Profiling system.
 *
 * The Profiler responds to Author profiling requests.
 *
 * IMPORTANT: Currently only works with dummy values. It is not currently linked
 * to the profiling system.
 */

import * as child_process from 'child_process'; //require('child_process').execFile;
import { BackendWrapper } from '../backend_wrapper';
const execFile = child_process.execFile;
 
import { FromClientProfiling, ToClientProfiling, FromClientProfiling_isValid } from './network_interface';

export class Profiler extends BackendWrapper< FromClientProfiling > {
  constructor( ) {
    super( FromClientProfiling_isValid );
  }

  // Callback that gets called once the Python program has finished
  // TODO: Wrap this with a task class
  private programFinishedCallback( callback: ( out: any ) => void, error, stdout, stderr ) {
    if ( error ) {
      console.log( error );
      callback( 'An error occurred' );
      return;
    }
    
    try {
      let out: ToClientProfiling = JSON.parse( stdout );
      callback( out );
    } catch ( ex ) {
      callback( 'An error occurred' );
    }
  }
  
  // Override
  protected doHandleRequest( request: FromClientProfiling, callback: ( out: any ) => void ): void {
    // Command: python3 predict.py <language> <text>
    // TODO: Make sure language input field is semantically validated
    const args = [ 'predict.py',
                   request.language,
                   request.text ];
    const options = { cwd: 'resources/glad/simple-age-gender' };
        
    execFile( 'python3', args, options, this.programFinishedCallback.bind( this, callback ) );
  }
}
