import * as assert from 'assert';
import * as express from 'express';
import * as http from 'http';
import * as path from 'path';
import * as net from 'net';
import { appApi } from '../src/api';
import { Attributor } from '../src/attribution/attributor';

describe( 'API', ( ) => {
  describe( 'Attributor', ( ) => {
    let attributor: Attributor = new Attributor( );
    let request = { knownAuthorTexts: [ 'Hello World! Lorem Ipsum dolor sit amet' ]
                  , unknownAuthorText: 'Rose is a rose is a rose'
                  , language: 'EN'
                  , genre: 'novel'
                  , featureSet: 4 };

    let falseRequest = { blob: 'Random stuff' };
    
    // There is no model for Spanish Novels
    let invalidRequest = { knownAuthorTexts: [ 'Hello World! Lorem Ipsum dolor sit amet' ]
                         , unknownAuthorText: 'Rose is a rose is a rose'
                         , language: 'SP'
                         , genre: 'novel'
                         , featureSet: 4 };

    it( 'should perform request', ( ) => {
      attributor.handleRequest( request, ( out: any ) => {
        assert.equal( out.sameAuthorConfidence, true, 'Result has a confidence level' );
        assert.equal( out.statistics, true, 'Result statistics' );
      } );
    });
    
    it( 'should reject invalidly formatted requests', ( ) => {
      attributor.handleRequest( request, ( out: any ) => {
        assert.equal( out, 'An error occurred', 'Invalid request rejected' );
      } );
    });
    
    it( 'should notify of missing models', ( ) => {
      attributor.handleRequest( request, ( out: any ) => {
        assert.equal( out, 'Invalid request', 'Notified of missing model' );
      } );
    });
  });
});

// Sort of regression tests
describe( 'HTTP', ( ) => {
  let webserver;
  let isClosed = false;
  
  beforeEach( ( doneCallback ) => {
    webserver = setupWebserver( doneCallback );
    webserver.on( 'close', ( ) => { isClosed = true; } );
    isClosed = false;
  } );
  
  afterEach( ( doneCallback ) => {
    webserver.close( doneCallback );
  } );
  
  it( 'should not crash when non-HTTP clients connect', ( ) => {
    let client = new net.Socket( );
    client.connect( 8080, 'localhost', ( ) => {
      client.destroy( );
      assert.equal( isClosed, false, 'Server did not crash from non-HTTP client' );
    });
  } );
  
  it( 'should not crash from an invalid HTTP request', ( ) => {
    let client = new net.Socket( );
    client.connect( 8080, 'localhost', ( ) => {
      client.write( 'GET / HTTP/1.1\nNo, this is not HTTP\n\n' );
      client.destroy( );
      assert.equal( isClosed, false, 'Server did not crash from invalid HTTP request' );
    });
  } );
} );

// Duplicate of index, with added functionality of turning it off after the tests
function setupWebserver( callback ) {
  const app = express( );

  // Bind api to '/api'
  app.use( '/api', appApi );

  // Bind the 'public_html' directory to '/' for all remaining resources
  app.use( express.static( 'public_html' ) );

  // Any other resource not previously mentioned - Serve index
  app.all( '*', ( req, res ) => {
    res.status( 200 );
    res.sendFile( path.join( __dirname, '/public_html/index.html' ) );
  } );

  // Start server using 'http'. Useful when later HTTPS is used
  return http.createServer( app ).listen( 8080, ( ) => {
    //console.log( 'Running' );
    callback( );
  } );
}