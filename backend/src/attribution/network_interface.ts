/**
 * The network interface for the Authorship Attribution API
 */

 
/**
 * The message requesting an Authorship verification.
 *
 * Also known as: ToServerAttribution
 */
export interface FromClientAttribution {
  knownAuthorTexts: string[];
  unknownAuthorText: string;
  language: string;
  genre: string;
  featureSet: number;
}

/**
 * True if the request is a valid 'FromClientAttribution' interface
 */
export function FromClientAttribution_isValid( request: any ): boolean {
  // TODO: More in-depth validity testing
  return ( request.knownAuthorTexts instanceof Array &&
           typeof request.unknownAuthorText === 'string' &&
           typeof request.language === 'string' &&
           typeof request.genre === 'string' &&
           typeof request.featureSet === 'number' );
}

/**
 * The message responding to an Authorship verification, in case of success
 *
 * Also known as: FromClientAttribution
 */
export interface ToClientAttribution {
  sameAuthorConfidence: number;
  statistics: any;
}
