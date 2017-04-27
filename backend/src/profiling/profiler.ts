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
  
  // Override
  protected doHandleRequest( request: FromClientProfiling, callback: ( out: any ) => void ): void {
    let out: ToClientProfiling = { gender: 'M', age: 10 };
    callback( out );
  }
}
