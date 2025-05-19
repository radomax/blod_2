-- Opprett standard administrator-bruker-- MySQL Database Schema for Mortalitet (Dødsårsaksregistrering)
-- Denne SQL-filen oppretter nødvendige tabeller for dødsårsaksregistrering

-- Opprett database (Kjør dette først)
CREATE DATABASE IF NOT EXISTS mortalitet CHARACTER SET utf8mb4 COLLATE utf8mb4_danish_ci;
USE mortalitet;

-- Brukertabell for autentisering og autorisasjon
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Lagrer passordhash, ikke klartekst
    role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    email VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    institution VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    active BOOLEAN DEFAULT TRUE
);

-- Referansetabell for ICD-koder
CREATE TABLE icd_codes (
    code_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    parent_code VARCHAR(10) NULL, -- For hierarkisk struktur
    icd_chapter VARCHAR(10) NULL, -- Kapittelkode (f.eks. I00-I99)
    is_active BOOLEAN DEFAULT TRUE,
    INDEX (code),
    INDEX (parent_code),
    INDEX (icd_chapter)
);

-- Hovedtabell for dødsregistreringer
CREATE TABLE death_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL,
    patient_age INT NOT NULL,
    patient_gender ENUM('male', 'female', 'other') NOT NULL,
    patient_residence VARCHAR(100) NOT NULL,
    death_date DATE NOT NULL,
    death_context ENUM('natural', 'accident', 'suicide', 'homicide', 'unknown') NOT NULL,
    autopsy_performed ENUM('yes', 'no') NOT NULL DEFAULT 'no',
    registered_by INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_by INT NULL,
    last_updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    additional_info TEXT NULL,
    FOREIGN KEY (registered_by) REFERENCES users(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES users(user_id),
    INDEX (patient_id),
    INDEX (death_date),
    INDEX (death_context)
);

-- Tabell for registrering av dødsårsaker (én registrering kan ha flere dødsårsaker)
CREATE TABLE death_causes (
    cause_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    cause_type ENUM('primary', 'secondary', 'underlying') NOT NULL,
    icd_code VARCHAR(10) NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (record_id) REFERENCES death_records(record_id) ON DELETE CASCADE,
    FOREIGN KEY (icd_code) REFERENCES icd_codes(code),
    INDEX (record_id),
    INDEX (cause_type),
    INDEX (icd_code)
);

-- Tabell for revisjonerhistorikk
CREATE TABLE record_revisions (
    revision_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    revision_type ENUM('create', 'update', 'delete') NOT NULL,
    revision_data JSON NOT NULL, -- Lagrer en JSON-representasjon av registreringen på revisjonstidspunktet
    revised_by INT NOT NULL,
    revised_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revision_notes TEXT NULL,
    FOREIGN KEY (record_id) REFERENCES death_records(record_id) ON DELETE CASCADE,
    FOREIGN KEY (revised_by) REFERENCES users(user_id),
    INDEX (record_id),
    INDEX (revised_at)
);

-- Tabell for kontaktforespørsler
CREATE TABLE contact_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject ENUM('question', 'correction', 'tech', 'other') NOT NULL,
    message TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_by INT NULL,
    resolved_at TIMESTAMP NULL,
    resolution_notes TEXT NULL,
    FOREIGN KEY (resolved_by) REFERENCES users(user_id),
    INDEX (submitted_at),
    INDEX (is_resolved)
);

-- Tabell for systemlogg
CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_type ENUM('info', 'warning', 'error', 'security') NOT NULL,
    log_message TEXT NOT NULL,
    log_source VARCHAR(50) NOT NULL,
    user_id INT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX (log_type),
    INDEX (created_at)
);


-- Fyll inn noen standard ICD-koder (kapitler)
INSERT INTO icd_codes (code, description, parent_code, icd_chapter, is_active) VALUES
('A00-B99', 'Visse infeksjonssykdommer og parasittsykdommer', NULL, 'A00-B99', TRUE),
('C00-D48', 'Svulster', NULL, 'C00-D48', TRUE),
('D50-D89', 'Sykdommer i blod og bloddannende organer og visse tilstander som angår immunsystemet', NULL, 'D50-D89', TRUE),
('E00-E90', 'Endokrine sykdommer, ernæringssykdommer og metabolske forstyrrelser', NULL, 'E00-E90', TRUE),
('F00-F99', 'Psykiske lidelser og atferdsforstyrrelser', NULL, 'F00-F99', TRUE),
('G00-G99', 'Sykdommer i nervesystemet', NULL, 'G00-G99', TRUE),
('H00-H59', 'Sykdommer i øyet og øyets omgivelser', NULL, 'H00-H59', TRUE),
('H60-H95', 'Sykdommer i øre og ørebensknute', NULL, 'H60-H95', TRUE),
('I00-I99', 'Sykdommer i sirkulasjonssystemet', NULL, 'I00-I99', TRUE),
('J00-J99', 'Sykdommer i åndedrettssystemet', NULL, 'J00-J99', TRUE),
('K00-K93', 'Sykdommer i fordøyelsessystemet', NULL, 'K00-K93', TRUE),
('L00-L99', 'Sykdommer i hud og underhud', NULL, 'L00-L99', TRUE),
('M00-M99', 'Sykdommer i muskel-skjelettsystemet og bindevev', NULL, 'M00-M99', TRUE),
('N00-N99', 'Sykdommer i urin- og kjønnsorganene', NULL, 'N00-N99', TRUE),
('O00-O99', 'Svangerskap, fødsel og barseltid', NULL, 'O00-O99', TRUE),
('P00-P96', 'Visse tilstander som oppstår i perinatalperioden', NULL, 'P00-P96', TRUE),
('Q00-Q99', 'Medfødte misdannelser, deformiteter og kromosomavvik', NULL, 'Q00-Q99', TRUE),
('R00-R99', 'Symptomer, tegn og unormale kliniske funn og laboratoriefunn, ikke klassifisert annet sted', NULL, 'R00-R99', TRUE),
('S00-T98', 'Skader, forgiftninger og visse andre konsekvenser av ytre årsaker', NULL, 'S00-T98', TRUE),
('V01-Y98', 'Ytre årsaker til sykdommer, skader og dødsfall', NULL, 'V01-Y98', TRUE),
('Z00-Z99', 'Faktorer som har betydning for helsetilstand og kontakt med helsetjenesten', NULL, 'Z00-Z99', TRUE),
('U00-U99', 'Koder for spesielle formål', NULL, 'U00-U99', TRUE);

-- Legg til noen vanlige dødsårsaker
INSERT INTO icd_codes (code, description, parent_code, icd_chapter, is_active) VALUES
('I21', 'Akutt hjerteinfarkt', NULL, 'I00-I99', TRUE),
('I21.0', 'Akutt transmuralt hjerteinfarkt i fremre vegg', 'I21', 'I00-I99', TRUE),
('I21.1', 'Akutt transmuralt hjerteinfarkt i nedre vegg', 'I21', 'I00-I99', TRUE),
('I21.2', 'Akutt transmuralt hjerteinfarkt med annen lokalisasjon', 'I21', 'I00-I99', TRUE),
('I21.3', 'Akutt transmuralt hjerteinfarkt med uspesifisert lokalisasjon', 'I21', 'I00-I99', TRUE),
('I21.4', 'Akutt subendokardialt infarkt', 'I21', 'I00-I99', TRUE),
('I21.9', 'Uspesifisert akutt hjerteinfarkt', 'I21', 'I00-I99', TRUE),
('I25', 'Kronisk iskemisk hjertesykdom', NULL, 'I00-I99', TRUE),
('I50', 'Hjertesvikt', NULL, 'I00-I99', TRUE),
('I63', 'Hjerneinfarkt', NULL, 'I00-I99', TRUE),
('I64', 'Hjerneslag, ikke spesifisert som blødning eller infarkt', NULL, 'I00-I99', TRUE),
('C34', 'Ondartet svulst i bronkie og lunge', NULL, 'C00-D48', TRUE),
('C34.9', 'Uspesifisert ondartet svulst i bronkie og lunge', 'C34', 'C00-D48', TRUE),
('C50', 'Ondartet svulst i bryst', NULL, 'C00-D48', TRUE),
('J44', 'Annen kronisk obstruktiv lungesykdom', NULL, 'J00-J99', TRUE),
('J44.9', 'Uspesifisert kronisk obstruktiv lungesykdom', 'J44', 'J00-J99', TRUE),
('E11', 'Diabetes mellitus type 2', NULL, 'E00-E90', TRUE),
('E11.9', 'Diabetes mellitus type 2 uten komplikasjoner', 'E11', 'E00-E90', TRUE),
('F10', 'Psykiske lidelser og atferdsforstyrrelser som skyldes bruk av alkohol', NULL, 'F00-F99', TRUE),
('F10.2', 'Alkoholavhengighetssyndrom', 'F10', 'F00-F99', TRUE),
('G30', 'Alzheimers sykdom', NULL, 'G00-G99', TRUE),
('G30.9', 'Uspesifisert Alzheimers sykdom', 'G30', 'G00-G99', TRUE),
('X60-X84', 'Villet egenskade', NULL, 'V01-Y98', TRUE),
('V01-V99', 'Transportulykker', NULL, 'V01-Y98', TRUE);

-- Indekser for ytelse
CREATE INDEX idx_death_date ON death_records(death_date);
CREATE INDEX idx_icd_code ON death_causes(icd_code);
CREATE INDEX idx_cause_type ON death_causes(cause_type);
CREATE INDEX idx_patient_age ON death_records(patient_age);
CREATE INDEX idx_patient_gender ON death_records(patient_gender);
CREATE INDEX idx_patient_residence ON death_records(patient_residence);

-- Sett opp vyer for vanlige spørringer
CREATE VIEW view_recent_deaths AS
SELECT dr.record_id, dr.patient_id, dr.patient_age, dr.patient_gender, dr.death_date, 
       dr.death_context, dc.icd_code, dc.description
FROM death_records dr
JOIN death_causes dc ON dr.record_id = dc.record_id AND dc.cause_type = 'primary'
WHERE dr.death_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
ORDER BY dr.death_date DESC;

CREATE VIEW view_top_causes AS
SELECT dc.icd_code, ic.description, COUNT(*) as count
FROM death_causes dc
JOIN death_records dr ON dc.record_id = dr.record_id
JOIN icd_codes ic ON dc.icd_code = ic.code
WHERE dc.cause_type = 'primary'
GROUP BY dc.icd_code, ic.description
ORDER BY count DESC
LIMIT 10;

