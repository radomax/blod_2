-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: db:3306
-- Generation Time: May 18, 2025 at 12:16 PM
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
-- Table structure for table `death_records`
--

CREATE TABLE `death_records` (
  `record_id` int NOT NULL,
  `patient_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_age` int NOT NULL,
  `patient_gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_residence` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `death_date` date NOT NULL,
  `death_context` enum('natural','accident','suicide','homicide','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `autopsy_performed` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'no',
  `registered_by` int NOT NULL,
  `registered_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_by` int DEFAULT NULL,
  `last_updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `additional_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `death_records`
--

INSERT INTO `death_records` (`record_id`, `patient_id`, `patient_age`, `patient_gender`, `patient_residence`, `death_date`, `death_context`, `autopsy_performed`, `registered_by`, `registered_at`, `last_updated_by`, `last_updated_at`, `additional_info`) VALUES
(1, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-04-27 16:44:44', NULL, NULL, ''),
(2, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-04 00:57:43', NULL, NULL, ''),
(3, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-04 00:58:30', NULL, NULL, ''),
(6, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-04 01:07:36', NULL, NULL, ''),
(7, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-18 12:01:43', NULL, NULL, ''),
(8, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-18 12:02:41', NULL, NULL, 'adfasdfasdfasdfd'),
(9, 'P12345', 95, 'female', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-18 12:15:06', NULL, NULL, ''),
(10, 'P12345', 89, 'female', 'ams', '2025-01-15', 'natural', 'no', 1, '2025-05-18 12:15:28', NULL, NULL, ''),
(11, 'P12345', 65, 'male', 'Oslo', '2025-01-15', 'natural', 'no', 1, '2025-05-18 12:15:51', NULL, NULL, 'Testregistrering fra direkte API-kall');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `death_records`
--
ALTER TABLE `death_records`
  ADD PRIMARY KEY (`record_id`),
  ADD KEY `registered_by` (`registered_by`),
  ADD KEY `last_updated_by` (`last_updated_by`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `death_date` (`death_date`),
  ADD KEY `death_context` (`death_context`),
  ADD KEY `idx_death_date` (`death_date`),
  ADD KEY `idx_patient_age` (`patient_age`),
  ADD KEY `idx_patient_gender` (`patient_gender`),
  ADD KEY `idx_patient_residence` (`patient_residence`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `death_records`
--
ALTER TABLE `death_records`
  MODIFY `record_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `death_records`
--
ALTER TABLE `death_records`
  ADD CONSTRAINT `death_records_ibfk_1` FOREIGN KEY (`registered_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `death_records_ibfk_2` FOREIGN KEY (`last_updated_by`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
