-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: db:3306
-- Generation Time: May 19, 2025 at 03:35 PM
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
-- Database: `blood_pressure_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `blood_pressure_measurements`
--

CREATE TABLE `blood_pressure_measurements` (
  `id` int NOT NULL,
  `patient_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_age` int NOT NULL,
  `patient_gender` enum('male','female','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `measurement_date` date NOT NULL,
  `measurement_time` time NOT NULL,
  `referral_source` enum('maja','self','doctor','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `measurement1_sys` int DEFAULT NULL,
  `measurement1_dia` int DEFAULT NULL,
  `measurement2_sys` int NOT NULL,
  `measurement2_dia` int NOT NULL,
  `measurement3_sys` int NOT NULL,
  `measurement3_dia` int NOT NULL,
  `average_sys` int NOT NULL,
  `average_dia` int NOT NULL,
  `equipment` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'microlife-b2',
  `cuff_size` enum('S','M/L','L/XL') COLLATE utf8mb4_unicode_ci DEFAULT 'M/L',
  `arm_used` enum('left','right') COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `registered_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'System',
  `registered_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `blood_pressure_measurements`
--

INSERT INTO `blood_pressure_measurements` (`id`, `patient_id`, `patient_age`, `patient_gender`, `measurement_date`, `measurement_time`, `referral_source`, `measurement1_sys`, `measurement1_dia`, `measurement2_sys`, `measurement2_dia`, `measurement3_sys`, `measurement3_dia`, `average_sys`, `average_dia`, `equipment`, `cuff_size`, `arm_used`, `notes`, `registered_by`, `registered_at`) VALUES
(1, 'P1459', 76, 'male', '2025-05-19', '16:35:00', 'doctor', 137, 86, 152, 70, 159, 87, 156, 79, 'llp-bt', 'S', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 14:35:16'),
(2, 'P1513', 78, 'male', '2025-05-19', '17:32:00', 'self', 143, 74, 152, 88, 120, 71, 136, 80, 'llp-bt', 'M/L', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 15:33:31'),
(3, 'P3165', 45, 'male', '2025-05-19', '17:33:00', 'doctor', 128, 76, 142, 73, 131, 76, 137, 75, 'microlife-b2', 'L/XL', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 15:33:44'),
(4, 'P5854', 44, 'male', '2025-05-19', '17:34:00', 'maja', 143, 80, 143, 76, 131, 76, 137, 76, 'llp-bt', 'S', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 15:34:57');

-- --------------------------------------------------------

--
-- Stand-in structure for view `bp_categories`
-- (See below for the actual view)
--
CREATE TABLE `bp_categories` (
`id` int
,`patient_id` varchar(50)
,`average_sys` int
,`average_dia` int
,`bp_category` varchar(11)
,`measurement_date` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `bp_statistics`
-- (See below for the actual view)
--
CREATE TABLE `bp_statistics` (
`total_measurements` bigint
,`today_measurements` bigint
,`high_bp_count` bigint
,`avg_patient_age` decimal(11,0)
,`maja_referrals` bigint
);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('user','admin') COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `role`, `created_at`) VALUES
(1, 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '2025-05-19 13:42:19');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blood_pressure_measurements`
--
ALTER TABLE `blood_pressure_measurements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_patient_id` (`patient_id`),
  ADD KEY `idx_measurement_date` (`measurement_date`),
  ADD KEY `idx_registered_at` (`registered_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blood_pressure_measurements`
--
ALTER TABLE `blood_pressure_measurements`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

-- --------------------------------------------------------

--
-- Structure for view `bp_categories`
--
DROP TABLE IF EXISTS `bp_categories`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `bp_categories`  AS SELECT `blood_pressure_measurements`.`id` AS `id`, `blood_pressure_measurements`.`patient_id` AS `patient_id`, `blood_pressure_measurements`.`average_sys` AS `average_sys`, `blood_pressure_measurements`.`average_dia` AS `average_dia`, (case when ((`blood_pressure_measurements`.`average_sys` < 130) and (`blood_pressure_measurements`.`average_dia` < 85)) then 'Normal' when ((`blood_pressure_measurements`.`average_sys` < 140) and (`blood_pressure_measurements`.`average_dia` < 90)) then 'High Normal' when ((`blood_pressure_measurements`.`average_sys` < 180) and (`blood_pressure_measurements`.`average_dia` < 110)) then 'High' else 'Very High' end) AS `bp_category`, `blood_pressure_measurements`.`measurement_date` AS `measurement_date` FROM `blood_pressure_measurements` ;

-- --------------------------------------------------------

--
-- Structure for view `bp_statistics`
--
DROP TABLE IF EXISTS `bp_statistics`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `bp_statistics`  AS SELECT count(0) AS `total_measurements`, count((case when (`blood_pressure_measurements`.`measurement_date` = curdate()) then 1 end)) AS `today_measurements`, count((case when ((`blood_pressure_measurements`.`average_sys` >= 140) or (`blood_pressure_measurements`.`average_dia` >= 90)) then 1 end)) AS `high_bp_count`, round(avg(`blood_pressure_measurements`.`patient_age`),0) AS `avg_patient_age`, count((case when (`blood_pressure_measurements`.`referral_source` = 'maja') then 1 end)) AS `maja_referrals` FROM `blood_pressure_measurements` ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
