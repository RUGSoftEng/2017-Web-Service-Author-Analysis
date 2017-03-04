// ToServer
export interface FromClient {
  knownAuthorText: string;
  unknownAuthorText: string;
}

// FromServer
export interface ToClient {
  sameAuthor: boolean;
  confidence: number;
}