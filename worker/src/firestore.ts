// Minimal Firestore REST client (reads + array-remove transform).

type FsValue =
  | { stringValue: string }
  | { integerValue: string }
  | { doubleValue: number }
  | { booleanValue: boolean }
  | { nullValue: null }
  | { timestampValue: string }
  | { arrayValue: { values?: FsValue[] } }
  | { mapValue: { fields?: Record<string, FsValue> } };

/** Converts a Firestore REST value into plain JSON. */
export function decodeValue(v: FsValue): unknown {
  if ('stringValue' in v) return v.stringValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('nullValue' in v) return null;
  if ('timestampValue' in v) return v.timestampValue;
  if ('arrayValue' in v) return (v.arrayValue.values ?? []).map(decodeValue);
  if ('mapValue' in v) return decodeFields(v.mapValue.fields ?? {});
  return undefined;
}

export function decodeFields(fields: Record<string, FsValue>): Record<string, unknown> {
  return Object.fromEntries(Object.entries(fields).map(([k, val]) => [k, decodeValue(val)]));
}

export class Firestore {
  constructor(private projectId: string, private token: () => Promise<string>) {}

  private get base() {
    return `https://firestore.googleapis.com/v1/projects/${this.projectId}/databases/(default)/documents`;
  }

  async get(path: string): Promise<Record<string, unknown> | null> {
    const res = await fetch(`${this.base}/${path}`, { headers: { authorization: `Bearer ${await this.token()}` } });
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`firestore get ${path}: ${res.status}`);
    const doc = (await res.json()) as { fields?: Record<string, FsValue> };
    return decodeFields(doc.fields ?? {});
  }

  async arrayRemove(path: string, field: string, values: string[]): Promise<void> {
    const res = await fetch(`${this.base}:commit`.replace('/documents:commit', '/documents:commit'), {
      method: 'POST',
      headers: { authorization: `Bearer ${await this.token()}`, 'content-type': 'application/json' },
      body: JSON.stringify({
        writes: [{
          transform: {
            document: `projects/${this.projectId}/databases/(default)/documents/${path}`,
            fieldTransforms: [{ fieldPath: field, removeAllFromArray: { values: values.map((s) => ({ stringValue: s })) } }],
          },
        }],
      }),
    });
    if (!res.ok) throw new Error(`firestore commit: ${res.status}`);
  }
}
