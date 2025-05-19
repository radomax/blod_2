# Blodtrykksmålinger - Installasjon og Oppsett

## Database Setup

1. **Opprett database:**
   ```sql
   -- Kjør database schema (se database_schema.sql)
   ```

2. **Konfigurer API:**
   - Rediger `blood_pressure.php` med dine database-detaljer:
   ```php
   $host = 'localhost';
   $dbname = 'blood_pressure_db';
   $username = 'din_bruker';
   $password = 'ditt_passord';
   ```

## Fil struktur
```
project/
├── index.html
├── api/
│   └── blood_pressure.php
└── database_schema.sql
```

## Funksjoner

### Umiddelbar Resultatvisning
- Gjennomsnittet av måling 2 og 3 beregnes automatisk
- Blodtrykkskategori vises med farge-koding
- Anbefalinger gis basert på verdier:
  - **Normal** (<130/85): Fortsett sunt livsstil
  - **Høyt normal** (130-139/85-89): Vurder livsstilsendringer  
  - **Forhøyet** (140-179/90-109): Anbefales å konsultere lege
  - **Alvorlig forhøyet** (>180/110): Kontakt lege/legevakt umiddelbart

### Database Integration
- Alle målinger lagres i MySQL database
- Real-time statistikk fra database
- Admin-panel for å administrere registreringer
- Eksport-funksjonalitet

### Sikkerhet
- Input-validering på både frontend og backend
- Prepared statements for SQL-sikkerhet
- Error handling og logging

## Test med Sample Data
Systemet genererer automatisk testdata hvis databasen er tom.

## Deployment
1. Last opp filer til webserver
2. Opprett database og kjør schema
3. Sett korrekte database-tilkoblingsdetaljer
4. Sørg for at PHP har PDO MySQL-støtte