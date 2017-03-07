/**
 * The network interface for the Authorship Attribution API
 */

 
/**
 * The message requesting an Authorship verification.
 *
 * Also known as: ToServer
 */
export interface FromClient {
  knownAuthorText: string;
  unknownAuthorText: string;
}

/**
 * The message responding to an Authorship verification, in case of success
 *
 * Also known as: FromClient
 */
export interface ToClient {
  sameAuthor: boolean;
  confidence: number;
}