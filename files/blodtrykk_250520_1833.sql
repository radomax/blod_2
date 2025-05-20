-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: db:3306
-- Generation Time: May 20, 2025 at 04:32 PM
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
-- Database: `blodtrykk`
--

-- --------------------------------------------------------

--
-- Table structure for table `blood_pressure_measurements`
--

CREATE TABLE `blood_pressure_measurements` (
  `id` int NOT NULL,
  `patient_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_age` int NOT NULL,
  `patient_gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `measurement_date` date NOT NULL,
  `measurement_time` time NOT NULL,
  `referral_source` enum('maja','self','doctor','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `measurement1_sys` int DEFAULT NULL,
  `measurement1_dia` int DEFAULT NULL,
  `measurement2_sys` int NOT NULL,
  `measurement2_dia` int NOT NULL,
  `measurement3_sys` int NOT NULL,
  `measurement3_dia` int NOT NULL,
  `average_sys` int NOT NULL,
  `average_dia` int NOT NULL,
  `equipment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'microlife-b2',
  `cuff_size` enum('S','M/L','L/XL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'M/L',
  `arm_used` enum('left','right') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `registered_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'System',
  `registered_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `blood_pressure_measurements`
--

INSERT INTO `blood_pressure_measurements` (`id`, `patient_id`, `patient_age`, `patient_gender`, `measurement_date`, `measurement_time`, `referral_source`, `measurement1_sys`, `measurement1_dia`, `measurement2_sys`, `measurement2_dia`, `measurement3_sys`, `measurement3_dia`, `average_sys`, `average_dia`, `equipment`, `cuff_size`, `arm_used`, `notes`, `registered_by`, `registered_at`) VALUES
(1, 'P1459', 76, 'male', '2025-05-19', '16:35:00', 'doctor', 137, 86, 152, 70, 159, 87, 156, 79, 'llp-bt', 'S', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 14:35:16'),
(2, 'P1513', 78, 'male', '2025-05-19', '17:32:00', 'self', 143, 74, 152, 88, 120, 71, 136, 80, 'llp-bt', 'M/L', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 15:33:31'),
(3, 'P3165', 45, 'male', '2025-05-19', '17:33:00', 'doctor', 128, 76, 142, 73, 131, 76, 137, 75, 'microlife-b2', 'L/XL', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 15:33:44'),
(4, 'P5854', 44, 'male', '2025-05-19', '17:34:00', 'maja', 143, 80, 143, 76, 131, 76, 137, 76, 'llp-bt', 'S', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 15:34:57'),
(5, 'P6707', 40, 'female', '2025-05-19', '19:29:00', 'doctor', 127, 89, 122, 81, 144, 78, 133, 80, 'microlife-b2', 'M/L', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 17:29:18'),
(6, 'P8103', 67, 'female', '2025-05-19', '19:29:00', 'doctor', 123, 72, 131, 79, 145, 75, 138, 77, 'microlife-b2', 'S', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 17:29:37'),
(7, 'P6078', 63, 'male', '2025-05-19', '19:29:00', 'maja', 155, 71, 131, 85, 152, 76, 142, 81, 'microlife-b6', 'M/L', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 17:29:48'),
(8, 'P2562', 61, 'female', '2025-05-19', '19:40:00', 'doctor', 125, 72, 124, 80, 149, 77, 137, 79, 'microlife-b6', 'L/XL', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 17:40:51'),
(9, 'P2128', 57, 'female', '2025-05-19', '19:41:00', 'maja', 131, 82, 133, 80, 156, 79, 145, 80, 'llp-bt', 'S', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 17:41:14'),
(10, 'P7858', 36, 'female', '2025-05-19', '19:44:00', 'self', 128, 88, 126, 75, 134, 67, 130, 71, 'microlife-b6', 'M/L', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 17:44:47'),
(11, 'P7343', 46, 'male', '2025-05-19', '22:22:00', 'doctor', 145, 80, 164, 74, 169, 72, 167, 73, 'microlife-b2', 'S', 'right', 'måling', 'System', '2025-05-19 20:23:13'),
(12, 'P6125', 57, 'male', '2025-05-19', '22:53:00', 'maja', 121, 79, 119, 81, 112, 84, 116, 83, 'microlife-b2', 'M/L', 'right', 'k', 'System', '2025-05-19 20:53:31'),
(13, 'P8633', 62, 'male', '2025-05-19', '22:54:00', 'self', 125, 88, 150, 85, 141, 79, 146, 82, 'llp-bt', 'L/XL', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 20:54:49'),
(14, 'P3595', 74, 'male', '2025-05-19', '23:18:00', 'self', 149, 72, 128, 76, 121, 80, 125, 78, 'microlife-b2', 'M/L', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 21:18:12'),
(15, 'P10151', 54, 'female', '2025-05-19', '23:25:00', 'self', 130, 87, 139, 81, 140, 74, 140, 78, 'microlife-b6', 'M/L', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 21:25:59'),
(16, 'P2180', 76, 'male', '2025-05-19', '23:28:00', 'doctor', 121, 73, 129, 77, 139, 73, 134, 75, 'llp-bt', 'S', 'left', 'Test måling generert automatisk', 'System', '2025-05-19 21:28:01'),
(17, 'wro', 37, 'male', '2025-05-19', '00:21:00', 'self', 125, 82, 112, 79, 121, 80, 117, 80, 'microlife-b2', 'M/L', 'right', 'Test måling generert automatisk', 'System', '2025-05-19 22:26:13'),
(18, 'Ukjent', 0, 'other', '2025-05-19', '01:11:00', 'other', NULL, NULL, 150, 90, 135, 80, 143, 85, 'microlife-b2', 'M/L', 'left', 'rtyrsfg', 'System', '2025-05-19 23:13:18'),
(19, 'Ukjent', 0, 'other', '2025-05-19', '01:35:00', 'other', NULL, NULL, 150, 90, 140, 85, 145, 88, 'microlife-b2', 'L/XL', 'left', 'yuiyui', 'System', '2025-05-19 23:36:06'),
(20, 'Ukjent', 0, 'other', '2025-05-20', '18:30:00', 'other', NULL, NULL, 105, 65, 101, 62, 103, 64, 'microlife-b2', 'S', 'left', NULL, 'System', '2025-05-20 16:31:57');

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
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('user','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'user',
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

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
