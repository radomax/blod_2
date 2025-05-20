# Blodtrykksmålinger - Svelte

Et moderne web-basert system for registrering og håndtering av blodtrykksmålinger i apotek.

## Funksjoner

- **Registrering**: Enkel registrering av blodtrykksmålinger med automatisk gjennomsnittskalkulation
- **Statistikk**: Oversikt over registrerte målinger med grunnleggende statistikk
- **Eksport**: Eksporter data i CSV eller JSON format
- **Administrasjon**: Administratorpanel for håndtering av registreringer
- **Brukerautentisering**: Innlogging med roller (ansatt/administrator)

## Teknologi

- **Svelte**: Moderne og reaktivt JavaScript-rammeverk
- **SvelteKit**: Full-stack rammeverk for Svelte-applikasjoner
- **Vite**: Rask build-verktøy og utviklingsserver
- **MySQL**: Database for lagring av registreringer
- **Docker**: Containerisering for enkel deployment

## Installasjon

### Forutsetninger

- Node.js 18+ 
- Docker og Docker Compose (for database)
- MySQL 8.0+ (hvis du ikke bruker Docker)

### Oppsett

1. **Klon prosjektet**
   ```bash
   git clone <repository-url>
   cd blodtrykk-svelte
   ```

2. **Installer avhengigheter**
   ```bash
   npm install
   ```

3. **Start database (Docker)**
   ```bash
   docker-compose up -d db
   ```

4. **Konfigurer miljøvariabler**
   Kopier `.env.example` til `.env` og juster verdiene:
   ```bash
   cp .env.example .env
   ```

5. **Start utviklingsserver**
   ```bash
   npm run dev
   ```

6. **Åpne applikasjonen**
   Gå til http://localhost:3023

## Skripter

- `npm run dev` - Start utviklingsserver
- `npm run build` - Bygg for produksjon
- `npm run preview` - Forhåndsvis produksjonsbygg
- `npm run check` - Sjekk TypeScript og Svelte kode

## Miljøvariabler

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=rado
DB_PASSWORD=2505
DB_NAME=blodtrykk
```

## Docker Deployment

For full deployment med Docker:

```bash
docker-compose up -d
```

Dette starter:
- Web-applikasjonen på port 3023
- MySQL database på port 13314
- phpMyAdmin på port 3024

## Struktur

```
src/
├── lib/
│   ├── components/     # Svelte komponenter
│   ├── stores/         # Svelte stores (state management)
│   ├── api/           # API funksjoner
│   └── db/            # Database konfigurasjon
├── routes/
│   └── api/           # API ruter
├── App.svelte         # Hovedkomponent
└── main.js           # Inngangspunkt
```

## Bidrag

1. Fork prosjektet
2. Lag en feature branch
3. Commit endringene
4. Push til branchen
5. Åpne en Pull Request

## Lisens

Dette prosjektet er lisensiert under MIT-lisensen - se LICENSE filen for detaljer.

## Støtte

For teknisk støtte, opprett et issue på GitHub eller bruk kontaktskjemaet i applikasjonen.