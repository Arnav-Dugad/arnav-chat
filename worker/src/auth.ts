import { createRemoteJWKSet, jwtVerify } from 'jose';
import { HttpError } from './env';

// Google's public keys for Firebase ID tokens (cached by jose + CF edge).
const JWKS = createRemoteJWKSet(
  new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'),
);

/** Verifies a Firebase ID token and returns the caller's uid. */
export async function verifyFirebaseToken(request: Request, projectId: string): Promise<string> {
  const header = request.headers.get('Authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  if (!token) throw new HttpError(401, 'missing token');
  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `https://securetoken.google.com/${projectId}`,
      audience: projectId,
      algorithms: ['RS256'],
    });
    if (!payload.sub || typeof payload.sub !== 'string') throw new Error('no sub');
    if (typeof payload.auth_time === 'number' && payload.auth_time * 1000 > Date.now() + 60_000) throw new Error('auth_time');
    return payload.sub;
  } catch {
    throw new HttpError(401, 'invalid token');
  }
}
