FROM node:18-bookworm

ARG PLAYWRIGHT_VERSION=1.52.0
ENV DEBIAN_FRONTEND=noninteractive \
    NPM_CONFIG_LOGLEVEL=warn

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g "playwright@${PLAYWRIGHT_VERSION}"
RUN npm install -g @shopware-ag/acceptance-test-suite
RUN npx playwright install --with-deps


RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --create-home --shell /bin/bash appuser

USER appuser

WORKDIR /home/appuser/app

# Die folgenden Zeilen sind Beispiele, wie Sie Ihren Anwendungscode hinzufügen würden:
# Kopieren Sie Ihre package.json und package-lock.json (oder yarn.lock, pnpm-lock.yaml)
# COPY --chown=appuser:appgroup package.json package-lock.json* ./

# Installieren Sie Ihre Projekt-Abhängigkeiten (ohne devDependencies für ein schlankes Image)
# RUN npm ci --omit=dev

# Kopieren Sie den Rest Ihres Anwendungscodes
# COPY --chown=appuser:appgroup . .

# Setzen Sie dumb-init als Entrypoint, um eine korrekte Signalverarbeitung zu gewährleisten
#ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Standardbefehl, der beim Starten des Containers ausgeführt wird.
# Dieses Beispiel prüft die Installation und Versionen der Playwright-Browser.
CMD ["node", "-e", "const { chromium, firefox, webkit } = require('playwright'); (async () => { try { console.log('Verifying Playwright browser installations:'); for (const browserType of [chromium, firefox, webkit]) { const browser = await browserType.launch(); console.log(`  ${browserType.name()} version: ${await browser.version()}`); await browser.close(); }} catch (err) { console.error('Error launching or verifying Playwright browsers:', err); process.exit(1); } })()"]

# Beispiel für die Ausführung Ihrer Tests (passen Sie dies an Ihr Projekt an):
ENTRYPOINT [ "npx", "playwright", "test" ]