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
  genre: number;
  featureSet: number;
}

/**
 * The message responding to an Authorship verification, in case of success
 *
 * Also known as: FromClientAttribution
 */
export interface ToClientAttribution {
  sameAuthorConfidence: number;
}