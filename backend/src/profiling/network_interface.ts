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
}

/**
 * True if the request is a valid 'FromClientProfiling' interface
 */
export function FromClientProfiling_isValid( request: any ): boolean {
  // TODO: More in-depth validity testing
  return ( typeof request.text === 'string' &&
           typeof request.language === 'string' );
}

/**
 * The message responding to an Authorship verification, in case of success
 *
 * Also known as: FromClientProfiling
 */
export interface ToClientProfiling {
  "Age groups": ToClientProfiling_AgeGroups;
  "Genders": ToClientProfiling_Genders;
}

export interface ToClientProfiling_AgeGroups {
  "18-24": number;
  "25-34": number;
  "35-49": number;
  "50-64": number;
  "65-xx": number;
}

export interface ToClientProfiling_Genders {
  Male: number;
  Female: number;
}
