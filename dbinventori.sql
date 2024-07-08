-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 08, 2024 at 08:50 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbinventori`
--

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `KD_BARANG` varchar(10) NOT NULL,
  `NAMA_BRG` varchar(255) NOT NULL,
  `SATUAN` varchar(11) NOT NULL,
  `QTY` int(11) NOT NULL,
  `HARGA` int(11) NOT NULL,
  `STOK_MIN` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`KD_BARANG`, `NAMA_BRG`, `SATUAN`, `QTY`, `HARGA`, `STOK_MIN`) VALUES
('A0001', 'KOMPUTER', 'pcs', 4, 4000000, 2),
('A0002', 'HUB', 'pcs', 3, 2300000, 2),
('B0001', 'MODEM', 'pcs', 5, 1400000, 3);

-- --------------------------------------------------------

--
-- Table structure for table `barang_supplier`
--

CREATE TABLE `barang_supplier` (
  `KD_SUP` varchar(10) NOT NULL,
  `KD_BARANG` varchar(10) NOT NULL,
  `HARGA` decimal(15,2) DEFAULT NULL,
  `DISC` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang_supplier`
--

INSERT INTO `barang_supplier` (`KD_SUP`, `KD_BARANG`, `HARGA`, `DISC`) VALUES
('S0001', 'A0001', '4000000.00', '5%'),
('S0001', 'A0002', '2300000.00', '0'),
('S0002', 'A0002', '2300000.00', '0'),
('S0002', 'B0001', '1400000.00', '0'),
('S0004', 'A0001', '4000000.00', '2%');

-- --------------------------------------------------------

--
-- Table structure for table `po`
--

CREATE TABLE `po` (
  `KT_TRANS` varchar(10) NOT NULL,
  `TGL_TRANS` date DEFAULT NULL,
  `KD_SUP` varchar(10) DEFAULT NULL,
  `USERID` varchar(10) DEFAULT NULL,
  `TOTAL_ITEM` int(11) DEFAULT NULL,
  `TOTAL_HARGA` decimal(15,2) DEFAULT NULL,
  `DISCOUNT` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `po`
--

INSERT INTO `po` (`KT_TRANS`, `TGL_TRANS`, `KD_SUP`, `USERID`, `TOTAL_ITEM`, `TOTAL_HARGA`, `DISCOUNT`) VALUES
('T0001', '2018-09-25', 'S0001', 'USR01', 3, '7700000.00', '200000.00'),
('T0002', '2018-09-25', 'S0004', 'USR02', 5, '14000000.00', '80000.00');

-- --------------------------------------------------------

--
-- Table structure for table `po_detail`
--

CREATE TABLE `po_detail` (
  `KD_TRANS` varchar(10) NOT NULL,
  `KD_BARANG` varchar(10) NOT NULL,
  `QTY` int(11) DEFAULT NULL,
  `HARGA` decimal(15,2) DEFAULT NULL,
  `DISC` varchar(10) DEFAULT NULL,
  `TOTAL_DISC` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `po_detail`
--

INSERT INTO `po_detail` (`KD_TRANS`, `KD_BARANG`, `QTY`, `HARGA`, `DISC`, `TOTAL_DISC`) VALUES
('T0001', 'A0001', 1, '4000000.00', '5%', '200000.00'),
('T0001', 'A0002', 1, '2300000.00', '-', NULL),
('T0001', 'B0001', 1, '1400000.00', '-', NULL),
('T0002', 'A0001', 2, '4000000.00', '2%', '80000.00'),
('T0002', 'A0002', 2, '2300000.00', '-', NULL),
('T0002', 'B0001', 1, '1400000.00', '-', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `KD_SUP` varchar(10) NOT NULL,
  `NAMA_SUP` varchar(100) DEFAULT NULL,
  `ALAMAT` text DEFAULT NULL,
  `KOTA` varchar(50) DEFAULT NULL,
  `TELP` varchar(20) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `PIC` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`KD_SUP`, `NAMA_SUP`, `ALAMAT`, `KOTA`, `TELP`, `EMAIL`, `PIC`) VALUES
('S0001', 'PT. ANDARA MAKMUR SEJATI', 'JL. BILANGAN TIMUR O 10', 'JAKARTA', '021.827383', 'HRD@AMS.CO.ID', 'BAKRI'),
('S0002', 'CV. MAJU BERSAMA', 'JL. WARINGIN JATI', 'BEKASI', '021.44353', NULL, 'AHMAD'),
('S0004', 'PT. KUMARA JAYA', 'JL. ISKANDAR', 'JAKARTA', '021.783384', 'MAP@KUMARAJAYA.CO.ID', 'KUMARA');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user`
--

CREATE TABLE `tbl_user` (
  `UserId` varchar(20) NOT NULL,
  `Password` varchar(50) DEFAULT NULL,
  `Status` varchar(1) DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_user`
--

INSERT INTO `tbl_user` (`UserId`, `Password`, `Status`) VALUES
('USR01', 'password123', 'Y'),
('USR02', 'mypassword', 'N'),
('USR03', 'securepass', 'Y'),
('USR04', 'admin2024', 'Y'),
('USR05', 'guestuser', 'N'),
('USR06', 'testpass', 'Y');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`KD_BARANG`);

--
-- Indexes for table `barang_supplier`
--
ALTER TABLE `barang_supplier`
  ADD PRIMARY KEY (`KD_SUP`,`KD_BARANG`),
  ADD KEY `KD_BARANG` (`KD_BARANG`);

--
-- Indexes for table `po`
--
ALTER TABLE `po`
  ADD PRIMARY KEY (`KT_TRANS`),
  ADD KEY `KD_SUP` (`KD_SUP`);

--
-- Indexes for table `po_detail`
--
ALTER TABLE `po_detail`
  ADD PRIMARY KEY (`KD_TRANS`,`KD_BARANG`),
  ADD KEY `KD_BARANG` (`KD_BARANG`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`KD_SUP`);

--
-- Indexes for table `tbl_user`
--
ALTER TABLE `tbl_user`
  ADD PRIMARY KEY (`UserId`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `barang_supplier`
--
ALTER TABLE `barang_supplier`
  ADD CONSTRAINT `barang_supplier_ibfk_1` FOREIGN KEY (`KD_SUP`) REFERENCES `supplier` (`KD_SUP`),
  ADD CONSTRAINT `barang_supplier_ibfk_2` FOREIGN KEY (`KD_BARANG`) REFERENCES `barang` (`KD_BARANG`);

--
-- Constraints for table `po`
--
ALTER TABLE `po`
  ADD CONSTRAINT `po_ibfk_1` FOREIGN KEY (`KD_SUP`) REFERENCES `supplier` (`KD_SUP`);

--
-- Constraints for table `po_detail`
--
ALTER TABLE `po_detail`
  ADD CONSTRAINT `po_detail_ibfk_1` FOREIGN KEY (`KD_TRANS`) REFERENCES `po` (`KT_TRANS`),
  ADD CONSTRAINT `po_detail_ibfk_2` FOREIGN KEY (`KD_BARANG`) REFERENCES `barang` (`KD_BARANG`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
