# phpMyAdmin Railway Deploy

## Innhold
- Dockerfile for phpMyAdmin
- railway.json for Railway deploy
- setup_db.php og init_database.php med PDO-tilkobling
- blood_pressure.php som eksempel på API

## Slik bruker du

1. `railway init`
2. Legg til følgende variables i Railway UI:
   - PMA_HOST
   - PMA_PORT
   - PMA_USER
   - PMA_PASSWORD
   - PMA_DATABASE

3. Kjør `railway up`

4. Besøk domenet Railway genererer.
