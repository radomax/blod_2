-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: db:3306
-- Generation Time: May 18, 2025 at 12:56 PM
-- Server version: 8.0.41
-- PHP Version: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mortalitet`
--

-- --------------------------------------------------------

--
-- Table structure for table `death_causes`
--

CREATE TABLE `death_causes` (
  `cause_id` int NOT NULL,
  `record_id` int NOT NULL,
  `cause_type` enum('primary','secondary','underlying') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `icd_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `death_causes`
--

INSERT INTO `death_causes` (`cause_id`, `record_id`, `cause_type`, `icd_code`, `description`) VALUES
(1, 1, 'primary', 'I21.9', 'Hjerteinfarkt'),
(2, 2, 'primary', 'I21.9', 'Hjerteinfarkt'),
(3, 3, 'primary', 'I21.9', 'Hjerteinfarkt'),
(6, 6, 'primary', 'I21.9', 'Hjerteinfarkt'),
(7, 7, 'primary', 'I21.9', 'Hjerteinfarkt'),
(8, 8, 'primary', 'I21.9', 'hjerne mut'),
(9, 9, 'primary', 'I21.9', 'Hjerteinfarkt'),
(10, 10, 'primary', 'I21.9', 'blodtrykk...'),
(11, 11, 'primary', 'I21.9', 'Hjerteinfarkt'),
(12, 11, 'secondary', 'E11.9', 'Diabetes type 2'),
(13, 11, 'underlying', 'F10.2', 'Alkoholavhengighet'),
(14, 12, 'primary', 'I21.9', 'blodtrykk...'),
(15, 13, 'primary', 'I21.9', 'blodtrykk...');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `death_causes`
--
ALTER TABLE `death_causes`
  ADD PRIMARY KEY (`cause_id`),
  ADD KEY `record_id` (`record_id`),
  ADD KEY `cause_type` (`cause_type`),
  ADD KEY `icd_code` (`icd_code`),
  ADD KEY `idx_icd_code` (`icd_code`),
  ADD KEY `idx_cause_type` (`cause_type`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `death_causes`
--
ALTER TABLE `death_causes`
  MODIFY `cause_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `death_causes`
--
ALTER TABLE `death_causes`
  ADD CONSTRAINT `death_causes_ibfk_1` FOREIGN KEY (`record_id`) REFERENCES `death_records` (`record_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `death_causes_ibfk_2` FOREIGN KEY (`icd_code`) REFERENCES `icd_codes` (`code`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
