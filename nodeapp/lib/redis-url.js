'use strict';

/**
 * Build a redis:// connection URL.
 *
 * The password belongs in the userinfo section, before the host and after '@'.
 * Getting this wrong produces `redis://host:port:password`, which node-redis
 * rejects with `TypeError: Invalid URL`.
 *
 * It must be percent-encoded: generated passwords routinely contain characters
 * that are significant in a URL (`+ / ? % : @ !`), and an unencoded `@` would
 * silently split the host.
 */
function buildRedisUrl({ host, port, password }) {
  if (!host) throw new Error('buildRedisUrl: host is required');

  const credentials = password
    ? `:${encodeURIComponent(password)}@`
    : '';

  return `redis://${credentials}${host}:${port || 6379}`;
}

module.exports = { buildRedisUrl };