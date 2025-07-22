-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 12, 2025 at 05:51 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `myborderlinkdb`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_officers`
--

CREATE TABLE `tbl_officers` (
  `officer_id` int(11) NOT NULL,
  `officer_fullname` varchar(100) NOT NULL,
  `officer_email` varchar(100) NOT NULL,
  `officer_password` varchar(255) NOT NULL,
  `officer_checkpoint` varchar(50) NOT NULL,
  `officer_datereg` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_officers`
--
ALTER TABLE `tbl_officers`
  ADD PRIMARY KEY (`officer_id`),
  ADD UNIQUE KEY `officer_email` (`officer_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_officers`
--
ALTER TABLE `tbl_officers`
  MODIFY `officer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Table structure for table `tbl_logs`
--

CREATE TABLE tbl_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    officer_id INT NOT NULL,
    date DATE NOT NULL,
    vehicle_plate VARCHAR(20) NOT NULL,
    inspection_type VARCHAR(50) NOT NULL,
    findings TEXT NOT NULL,
    location VARCHAR(100) NOT NULL,
    FOREIGN KEY (officer_id) REFERENCES tbl_officers(officer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
