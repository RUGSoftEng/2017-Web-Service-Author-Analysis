
/**
 * A wrapper around a backend system, that handles requests.
 */
export abstract class BackendWrapper< TInput > {
  private fIsValidInput: ( input: any ) => boolean;
  
  /**
   * \param fIsValidInput A function that verifies whether the input data
   *    satisfies the expected structure
   */
  public constructor( fIsValidInput: ( input: any ) => boolean ) {
    this.fIsValidInput = fIsValidInput;
  }
  
  /**
   * Handles a request. Upon finished the request, 'callback' should be called
   * with the results passed as a parameter.
   *
   * 'request' might not satisfy the expected input structure
   */
  public handleRequest( request: any, callback: ( out: any ) => void ): void {
    if ( !this.fIsValidInput( request ) ) {
      callback( 'Invalid input' );
    } else {
      this.doHandleRequest( request, callback );
    }
  }
  
  /**
   * Handles input request, of which the input structure has been validated.
   *
   * Subclasses should override this method by providing functionality
   * satisfying the needs of the wrapped backend system.
   *
   * \see handleRequest
   */
  protected abstract doHandleRequest( request: TInput, callback: ( out: any ) => void ): void;
}