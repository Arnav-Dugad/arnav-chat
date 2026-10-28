/** Cloudinary request signature: SHA-1 of sorted params + API secret. */
export async function cloudinarySignature(params: Record<string, string | number>, apiSecret: string): Promise<string> {
  const toSign = Object.keys(params)
    .sort()
    .map((k) => `${k}=${params[k]}`)
    .join('&');
  const data = new TextEncoder().encode(toSign + apiSecret);
  const digest = await crypto.subtle.digest('SHA-1', data);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

export const UPLOAD_KINDS = ['image', 'video', 'audio', 'file', 'avatar'] as const;
export type UploadKind = (typeof UPLOAD_KINDS)[number];
