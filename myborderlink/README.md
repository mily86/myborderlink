🚧 MyBorderLink App
A simple MyBorderLink App built with Flutter, PHP, and MySQL that allows customs officers to register and log in at an appointed checkpoint.


📱 App Purpose and Features
MyBorderLink is a mobile application designed for use by customs officers to securely register, log in, and manage their duty assignments at appointed checkpoints. It simplifies officer authentication and provides a user-friendly interface for identity verification.

✨ Key Features
•	🔐 Officer Registration
o	Collects Officer ID (numeric), Full Name, Email, Password, and Checkpoint
o	Validates inputs and enforces strong password rules
o	Stores passwords securely using PHP password_hash()
•	🔓 Secure Login
o	Officers log in using Officer ID and password
o	Credentials are verified via the PHP backend using password_verify()
o	On success, officer details are loaded to the homepage
•	📄 Homepage
o	Displays officer’s full name, ID, and checkpoint
o	Includes a clearly positioned Logout button
o	Prevents navigating back to login using system back button
•	💾 "Remember Me" Feature
o	Uses SharedPreferences to save login credentials locally (optional)
o	Automatically fills in saved data on app start
•	🛡️ Backend & Security
o	Passwords are never stored or sent in plain text
o	All user actions are validated
o	Duplicate email or ID is prevented during registration


🗃️ MySQL Table Structure

CREATE TABLE `tbl_officers` (
  `officer_id` INT(11) NOT NULL,
  `officer_fullname` VARCHAR(100) NOT NULL,
  `officer_email` VARCHAR(100) NOT NULL,
  `officer_password` VARCHAR(255) NOT NULL,
  `officer_checkpoint` VARCHAR(50) NOT NULL,
  `officer_datereg` DATETIME(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`officer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
📸 Screenshots

| Splash Screen | Register Screen |
|---------------|------------------------|
| ![Splash](assets/screenshots/ Splash Screen.png) | ![Register](assets/screenshots/ Register Screen.png) |















| Login Screen | Officer Screen |
|---------------|------------------------|
| ![Login](assets/screenshots/ Login Screen.png) | ![Officer](assets/screenshots/ Officer Screen.png) |













🔌 PHP Backend API

register_user.php
Handles officer registration. Validates unique email and officer ID, hashes the password, and inserts into the database.

login_user.php
Handles officer login. Accepts Officer ID and password, verifies the hashed password, and returns user details if successful.


## 🚀 How to Run the App

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/myborderlink.git
   cd myborderlink



This assignment helped me to understand several Flutter concepts:

•  Connecting Flutter with PHP backend via HTTP POST
•  Form validation and user feedback using TextEditingController and SnackBar
•  State management with setState and UI updates
•  Secure password hashing and verification in PHP using password_hash() and password_verify()
•  Session-like persistence with SharedPreferences



This assignment gave me practical experience with building a functional Flutter application. I learned how to manage app state and lifecycle with StatefulWidget and initState(). Besides, I’m also learned how to connect the Flutter frontend with a PHP/MySQL backend using HTTP requests. It also helped me to understand how to apply password hashing and backend integration using PHP and MySQL. Furthermore, I’m also learned about secure user registration and login functionality using hashed passwords. Overall, this assignment strengthened my understanding of Flutter's widget tree, communicating with external APIs and handling JSON responses, UI design principles, and error handling and feedback via SnackBars and conditional loading indicators.

