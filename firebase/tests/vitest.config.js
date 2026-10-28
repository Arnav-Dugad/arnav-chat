import { defineConfig } from 'vitest/config';

// All files share one emulator project and clear it between tests, so they
// must not run in parallel.
export default defineConfig({
  test: { fileParallelism: false, testTimeout: 15000 },
});
