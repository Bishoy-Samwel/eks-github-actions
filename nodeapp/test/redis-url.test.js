'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { buildRedisUrl } = require('../lib/redis-url');

test('omits userinfo when there is no password', () => {
  assert.strictEqual(
    buildRedisUrl({ host: 'redis-service', port: 6379 }),
    'redis://redis-service:6379'
  );
});

test('places the password in userinfo, not after the port', () => {
  // Regression test: `redis://host:port:password` throws Invalid URL.
  assert.strictEqual(
    buildRedisUrl({ host: 'redis-service', port: 6379, password: 's3cret' }),
    'redis://:s3cret@redis-service:6379'
  );
});

test('percent-encodes characters that are significant in a URL', () => {
  // A realistic generated password. ':' and '?' would each break parsing, and an
  // unencoded '@' would split the host from the credentials.
  // Note '!' is left as-is: encodeURIComponent treats it as a legal sub-delim.
  assert.strictEqual(
    buildRedisUrl({ host: 'redis-service', port: 6379, password: 'lTpsC-X?i@4?9Z!A%U:Tq' }),
    'redis://:lTpsC-X%3Fi%404%3F9Z!A%25U%3ATq@redis-service:6379'
  );
});

test('round-trips a hostile password through the URL parser', () => {
  const password = 'a:b@c/d?e#f%g';
  const url = new URL(buildRedisUrl({ host: 'redis-service', port: 6379, password }));

  assert.strictEqual(url.protocol, 'redis:');
  assert.strictEqual(url.hostname, 'redis-service');
  assert.strictEqual(url.port, '6379');
  assert.strictEqual(decodeURIComponent(url.password), password);
});

test('defaults the port to 6379', () => {
  assert.strictEqual(
    buildRedisUrl({ host: 'redis-service' }),
    'redis://redis-service:6379'
  );
});

test('rejects a missing host rather than emitting a broken URL', () => {
  assert.throws(() => buildRedisUrl({ port: 6379 }), /host is required/);
});