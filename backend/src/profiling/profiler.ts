/**
 * The Profiler is a wrapper around the Profiling system.
 *
 * The Profiler responds to Author profiling requests.
 *
 * IMPORTANT: Currently only works with dummy values. It is not currently linked
 * to the profiling system.
 */

import * as child_process from 'child_process'; //require('child_process').execFile;
const execFile = child_process.execFile;
 
import { FromClientProfiling, ToClientProfiling } from './network_interface';

export class Profiler {
  constructor( ) { }
  
  public handleRequest( request: FromClientProfiling, callback: ( out: any ) => void ) {
    if ( !this.isValid_FromClient( request ) ) {
      callback( 'Invalid input' );
      return;
    }
    
    let out: ToClientProfiling = { gender: 'M', age: 10 };
    callback( out );
  }
  
  /**
   * True if the request is a valid 'FromClientAttribution' interface
   */
  private isValid_FromClient( request: FromClientProfiling ): boolean {
    // TODO: More in-depth validity testing
    return ( typeof request.text === 'string' &&
             typeof request.language === 'string' &&
             typeof request.genre === 'number' &&
             typeof request.featureSet === 'number' );
  }
}
