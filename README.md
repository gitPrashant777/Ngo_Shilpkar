# Shilpkaar NGO Platform

## Overview

Shilpkaar is a comprehensive NGO management platform designed to bridge the gap between beneficiaries and government welfare schemes. The platform enables beneficiaries to connect with relevant schemes through a structured network of Village Coordinators and Directors while providing administrators with powerful tools for monitoring, management, and reporting.

The platform also includes a job portal, payment integration, beneficiary management system, and role-based access control to ensure secure and efficient operations.

---

## Features

### Role-Based Access Control (RBAC)

The platform supports multiple user roles:

* **Super Admin**

  * Complete system control
  * Manage administrators
  * Monitor platform activities
  * Access analytics and reports

* **Admin**

  * Manage users and coordinators
  * Verify beneficiary records
  * Manage schemes and services

* **Director**

  * Oversee operations across regions
  * Monitor coordinators
  * Track beneficiary progress

* **Village Coordinator**

  * Assist beneficiaries
  * Register and manage beneficiaries
  * Connect beneficiaries with government schemes
  * Monitor application progress

* **Beneficiary**

  * Browse available schemes
  * Apply for schemes
  * Track application status
  * Receive updates and notifications

* **User**

  * Explore platform information
  * Register as a beneficiary
  * Access public resources

---

## Government Scheme Management

* Browse government welfare schemes
* Scheme eligibility information
* Application tracking
* Beneficiary onboarding
* Coordinator-assisted registration process
* Status updates and notifications

---

## Beneficiary Management

* Beneficiary registration
* Profile management
* Document management
* Application tracking
* Scheme enrollment history
* Coordinator assignment

---

## Job Portal

* Job listings
* Employment opportunities
* Job application management
* Candidate tracking
* Employer and beneficiary engagement

---

## Payment Integration

Integrated with **Razorpay** for:

* Donations
* Membership fees
* Service payments
* Secure online transactions

---

## Cloud Infrastructure

The backend is powered by AWS Cloud Services for:

* Scalability
* Reliability
* Secure data storage
* Authentication and authorization
* API management

---

## Technology Stack

### Frontend

* Android
* Flutter
* Dart
* Material Design

### Backend

* AWS Cloud Services
* REST APIs

### Authentication

* Role-Based Authentication
* Secure Session Management

### Payment Gateway

* Razorpay

### Database

* Cloud-based Database Services

---

## Architecture

The application follows modern software architecture principles:

* MVVM Architecture
* Repository Pattern
* Dependency Injection
* Clean Code Practices
* Modular Design

---

## User Flow

1. User registers on the platform.
2. Beneficiary profile is created.
3. Village Coordinator verifies beneficiary details.
4. Beneficiary applies for eligible schemes.
5. Director and Admin monitor progress.
6. Beneficiary receives updates.
7. Payments and donations are processed securely through Razorpay.

---

## Security Features

* Role-Based Access Control
* Secure Authentication
* API Authorization
* Encrypted Data Transmission
* Secure Payment Processing

---

## Screenshots

Add application screenshots here.

### Login Screen

![Login Screen](screenshots/login.png)

### Dashboard

![Dashboard](screenshots/dashboard.png)

### Beneficiary Management

![Beneficiary](screenshots/beneficiary.png)

### Job Portal

![Job Portal](screenshots/job_portal.png)

---

## Installation

### Clone Repository

```bash
git clone https://github.com/gitPrashant777/Ngo_Shilpkar.git
```

### Open Project

```bash
Android Studio
```

### Build Project

```bash
Sync Gradle
Build Project
Run Application
```

---

## Project Structure

```text
app/
├── data/
│   ├── api/
│   ├── repository/
│   └── models/
│
├── domain/
│   ├── usecases/
│   └── entities/
│
├── presentation/
│   ├── ui/
│   ├── viewmodel/
│   └── adapters/
│
├── utils/
│
└── di/
```

---

## Future Enhancements

* Real-time chat between beneficiaries and coordinators
* AI-based scheme recommendations
* Multi-language support
* Document verification automation
* Analytics dashboard
* Push notifications
* Web portal support

---

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push the branch
5. Create a Pull Request

---

## License

This project is licensed under the MIT License.

---

## Author

**Prashant Kumar**

Android Developer | Software Engineer

GitHub: https://github.com/gitPrashant777

---

### Empowering Communities Through Technology

### Connecting Beneficiaries With Opportunities
