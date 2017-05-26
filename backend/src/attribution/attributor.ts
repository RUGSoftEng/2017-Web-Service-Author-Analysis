/**
 * The Attributor is a wrapper around the GLAD system.
 *
 * The Attributor responds to Authorship verification requests.
 */

import * as child_process from 'child_process'; //require('child_process').execFile;
import { BackendWrapper } from '../backend_wrapper';
import * as fs from 'fs';
import * as path from 'path';
const execFile = child_process.execFile;
 
import { FromClientAttribution, ToClientAttribution, FromClientAttribution_isValid } from './network_interface';

export class Attributor extends BackendWrapper<FromClientAttribution> {
  private static readonly PARAGRAPH_SEPARATOR: string = '\n\n';

  public constructor( ) {
    super( FromClientAttribution_isValid );
  }
  
  // Callback that gets called once the Python program has finished
  // TODO: Wrap this with a task class
  private programFinishedCallback( callback: ( out: any ) => void, error, stdout, stderr ) {
    if ( error ) {
      // console.log( error );
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
    let modelFilePath = `models/model_${request.language}_${request.genre}_${request.featureSet}`;
    
    fs.stat( path.join( 'resources/glad', modelFilePath ), ( err, stat ) => {
      if ( !err && stat.isDirectory( ) ) {
        const args = [ 'glad-copy.py',
                       '--inputknown', this.cleanInput( request.knownAuthorTexts.join( Attributor.PARAGRAPH_SEPARATOR ) ),
                       '--inputunknown', this.cleanInput( request.unknownAuthorText ),
                       '--combo', request.featureSet.toString(),
                       '-m', modelFilePath ];
        const options = { cwd: 'resources/glad' };
        
        execFile( 'python3', args, options, this.programFinishedCallback.bind( this, callback ) );
      } else {
        console.log( 'An invalid request was performed: ', request.language, request.genre, request.featureSet );
        callback( 'Invalid request' );
      }
    });
  }
}
