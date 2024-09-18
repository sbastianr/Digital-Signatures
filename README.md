# Digital Signature System

This project is part of the diploma in IT Infrastructure Management applied to business environments with a focus on information security. The system allows users to digitally sign files using public and private keys, while also protecting access with a firewall.

## Technologies
- **Backend**: Python (Flask)
- **Frontend**: Flutter
- **Database**: MariaDB
- **Firewall**: Alpine Linux with iptables
- **Containers**: Docker (each service in its own container)

## Features
- **User management**: Registration and authentication, including Gmail authentication via identity federation.
- **Key generation**: Users can generate and download pairs of public and private keys.
- **File signing**: Upload and digitally sign files using the user's private key.
- **Firewall**: Access control to system components using an iptables-based firewall.
- **Deployment with Docker Compose**: Each service runs in its own container for scalability and security.

## Security Practices
- **JWT Authentication**: Utilizes JWT with SHA-256 for secure authentication and token management.
- **Key Encryption**: RSA key generation is implemented using the cryptography library with 2048-bit keys.

## Deployment
The system is deployed using Docker Compose. It includes separate containers for each service:
1. **Firewall Container**: Controls access to system functions.
2. **Database Container**: MariaDB to store user and file information.
3. **Application Containers**: Backend and frontend services deployed in separate containers.

### Requirements
- Docker
- Docker Compose

### Installation
1. Clone the repository.
2. Configure the environment files for each service.
3. Run `docker-compose up` to start the containers.

---

### Contact
If you have any questions about the project, feel free to reach out to me via [LinkedIn](https://www.linkedin.com/in/sbastianr/)
