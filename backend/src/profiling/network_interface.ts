/**
 * The network interface for the Authorship Profiling API
 */

 
/**
 * The message requesting an Author profile.
 *
 * Also known as: ToServerProfiling
 */
export interface FromClientProfiling {
  text: string;
  language: string;
  genre: number;
  featureSet: number;
}

/**
 * True if the request is a valid 'FromClientAttribution' interface
 */
export function FromClientProfiling_isValid( request: any ): boolean {
  // TODO: More in-depth validity testing
  return ( typeof request.text === 'string' &&
           typeof request.language === 'string' &&
           typeof request.genre === 'number' &&
           typeof request.featureSet === 'number' );
}

/**
 * The message responding to an Authorship verification, in case of success
 *
 * Also known as: FromClientProfiling
 */
export interface ToClientProfiling {
  gender: string;
  age: number;
}