# syntax=docker/dockerfile:1
#
# Multi-stage so the runtime image does not carry npm.
#
# The single-stage version installed dependencies into the image that also
# contained /usr/local/lib/node_modules/npm. Trivy then reported 23 HIGH/CRITICAL
# CVEs in tar, brace-expansion, minimatch, glob, cross-spawn, pacote, sigstore,
# ip-address and http-cache-semantics — all of them npm's own bundled
# dependencies, none of them in this application's package-lock.json. The app
# never imports them, but they shipped in the image, which is what a scanner
# sees and what a real exploit would reach.
#
# The builder stage is discarded; only node_modules and the app are copied
# forward, so npm is not present at runtime at all.

# ── builder ──────────────────────────────────────────────────────────────
# Alpine 3.19 reached end of life, and the previous pin
# (node:20.12.2-alpine3.19) inherited its EOL package set: libcrypto3
# CVE-2024-6119, musl CVE-2025-26519 and CVE-2026-40200. This base is
# Alpine 3.24 and Node 22 LTS.
FROM node:22-alpine AS builder

WORKDIR /nodeapp

# Dependencies first so the install layer is cached until the lockfile changes.
COPY package*.json ./

# --omit=dev rather than --only=production: the latter is deprecated in npm 7+
# and npm warns about it on every run.
RUN npm ci --omit=dev


# ── runtime ──────────────────────────────────────────────────────────────
FROM node:22-alpine AS runtime

WORKDIR /nodeapp

ENV NODE_ENV=production

# Only the resolved dependency tree, not the npm that produced it.
COPY --from=builder /nodeapp/node_modules ./node_modules

COPY app.js ./
COPY lib ./lib

# The npm binary in the base image is not "just a tool" here: it bundles its own
# tar, brace-expansion, minimatch, glob, pacote and sigstore, which is where the
# 23 HIGH/CRITICAL findings came from. A multi-stage build alone does not remove
# them, because the runtime base image ships npm too. Nothing in a running
# container needs it, so delete it.
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/share/man/man1/npm* \
           /usr/local/share/man/man1/npx* \
 && rm -rf /root/.npm /home/node/.npm /home/node/.cache 2>/dev/null || true

# The base image ships a `node` user (uid 1000); use it rather than creating
# another.
USER node

EXPOSE 3000

CMD ["node", "app.js"]