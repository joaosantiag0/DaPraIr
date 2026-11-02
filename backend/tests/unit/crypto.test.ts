import { describe, it, expect } from 'vitest';
import { CryptoService } from '../../src/core/crypto/encryption.js';

describe('CryptoService', () => {
  it('should hash and verify passwords using Argon2id', async () => {
    const password = 'StrongPassword123!@#';
    const hash = await CryptoService.hashPassword(password);

    expect(hash).toBeDefined();
    expect(hash.startsWith('$argon2id$')).toBe(true);

    const isValid = await CryptoService.verifyPassword(hash, password);
    expect(isValid).toBe(true);

    const isInvalid = await CryptoService.verifyPassword(hash, 'WrongPassword');
    expect(isInvalid).toBe(false);
  });

  it('should encrypt and decrypt sensitive payloads with AES-256-GCM', () => {
    const payload = {
      disabilityTypes: ['WHEELCHAIR_POWERED'],
      assistanceNeeds: ['RAMP_REQUIRED', 'ADAPTED_RESTROOM'],
      notes: 'LGPD sensitive health data',
    };

    const encrypted = CryptoService.encryptPayload(payload);
    expect(Buffer.isBuffer(encrypted)).toBe(true);
    expect(encrypted.length).toBeGreaterThan(28); // 12 (iv) + 16 (tag) + ciphertext

    const decrypted = CryptoService.decryptPayload<typeof payload>(encrypted);
    expect(decrypted).toEqual(payload);
  });

  it('should generate consistent SHA-256 pseudonyms', () => {
    const ip = '192.168.1.100';
    const hash1 = CryptoService.hashPseudonym(ip);
    const hash2 = CryptoService.hashPseudonym(ip);

    expect(hash1).toBe(hash2);
    expect(hash1).toHaveLength(64);
  });
});
