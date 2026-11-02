import argon2 from 'argon2';
import crypto from 'node:crypto';
import { config } from '../../config.js';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12; // 96 bits recommended for GCM
const AUTH_TAG_LENGTH = 16; // 128 bits

export class CryptoService {
  /**
   * Hashes a password using Argon2id with OWASP recommended parameters
   */
  static async hashPassword(password: string): Promise<string> {
    return argon2.hash(password, {
      type: argon2.argon2id,
      memoryCost: 19456, // 19 MiB
      timeCost: 2,
      parallelism: 1,
    });
  }

  /**
   * Verifies a plaintext password against an Argon2id hash
   */
  static async verifyPassword(hash: string, password: string): Promise<boolean> {
    try {
      return await argon2.verify(hash, password);
    } catch {
      return false;
    }
  }

  /**
   * Encrypts sensitive LGPD data using AES-256-GCM
   * Returns a Buffer containing: [IV (12 bytes)][AuthTag (16 bytes)][Ciphertext]
   */
  static encryptPayload(data: unknown, hexKey: string = config.ENCRYPTION_KEY): Buffer {
    const key = Buffer.from(hexKey, 'hex');
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

    const plaintext = Buffer.from(JSON.stringify(data), 'utf8');
    const encrypted = Buffer.concat([cipher.update(plaintext), cipher.final()]);
    const authTag = cipher.getAuthTag();

    return Buffer.concat([iv, authTag, encrypted]);
  }

  /**
   * Decrypts AES-256-GCM payload buffer back to an object
   */
  static decryptPayload<T = unknown>(encryptedBuffer: Buffer, hexKey: string = config.ENCRYPTION_KEY): T {
    if (encryptedBuffer.length < IV_LENGTH + AUTH_TAG_LENGTH) {
      throw new Error('Invalid encrypted payload length');
    }

    const key = Buffer.from(hexKey, 'hex');
    const iv = encryptedBuffer.subarray(0, IV_LENGTH);
    const authTag = encryptedBuffer.subarray(IV_LENGTH, IV_LENGTH + AUTH_TAG_LENGTH);
    const ciphertext = encryptedBuffer.subarray(IV_LENGTH + AUTH_TAG_LENGTH);

    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);

    const decrypted = Buffer.concat([decipher.update(ciphertext), decipher.final()]);
    return JSON.parse(decrypted.toString('utf8')) as T;
  }

  /**
   * Hashes an IP or sensitive identifier with SHA-256 for pseudonymized audit logging
   */
  static hashPseudonym(value: string): string {
    return crypto.createHash('sha256').update(value).digest('hex');
  }
}
