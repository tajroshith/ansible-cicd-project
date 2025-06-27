# Secret Santa Generator CI/CD Pipeline

This project implements a Continuous Integration and Continuous Deployment (CI/CD) pipeline using Ansible for the Secret Santa Generator application. The pipeline automates the process of cloning the repository, building the application with Maven, performing code quality analysis with SonarQube, scanning the Docker image with Trivy, and deploying the application as a Docker container.

## Prerequisites

To set up and run this CI/CD pipeline, ensure the following tools and configurations are available on the target host:

- **Ubuntu-based system** (tested with Ubuntu)
- **Ansible** installed on the control node
- **Docker Hub account** for pushing Docker images
- **SonarQube server** accessible (default: `http://<host-ip>:9000`)
- **Ansible Vault** for encrypting sensitive credentials
- Required packages (installed via `installTools.yaml`):
  - `openjdk-17-jdk`
  - `net-tools`
  - `unzip`
  - `maven`
  - `docker`
  - `trivy`
  - `sonar-scanner`
  - `sonarqube` (run as a Docker container)

## Project Structure

The project includes the following key files:

- **`CICD.yaml`**: Ansible playbook that defines the CI/CD pipeline tasks, including cloning the repository, building the application, running tests, scanning code with SonarQube, building and scanning a Docker image, and deploying the application.
- **`credentials.yaml`**: Stores sensitive information such as Docker Hub credentials and SonarQube token. This file must be encrypted using Ansible Vault.
- **`docker-condition.sh`**: Shell script to check, stop, and remove the existing `secret-santa` Docker container before redeployment.
- **`installTools.yaml`**: Ansible playbook to install all necessary tools and dependencies on the target host, including Java, Maven, Docker, Trivy, and SonarQube.

## Setup Instructions

1. **Clone the Repository**
   - Ensure the target host has access to the repository: `https://github.com/tajroshith/secretsanta-generator.git`.

2. **Encrypt Credentials**
   - Edit `credentials.yaml` to include your Docker Hub username, password, SonarQube server url and SonarQube token.
   - Encrypt the file using Ansible Vault:
     ```bash
     ansible-vault encrypt credentials.yaml
     ```

3. **Install Prerequisites**
   - Run the `installTools.yaml` playbook to set up the required tools on the target host:
     ```bash
     ansible-playbook -i inventory installTools.yaml
     ```
   - This playbook installs Java, Maven, Docker, Trivy, SonarQube, and other dependencies, and starts a SonarQube container on port `9000`.

4. **Run the CI/CD Pipeline**
   - Execute the `CICD.yaml` playbook to run the full pipeline:
     ```bash
     ansible-playbook -i inventory CICD.yaml  --ask-vault-pass
     ```
   - Provide the Ansible Vault password when prompted to decrypt `credentials.yaml`.

## CI/CD Pipeline Workflow

The `CICD.yaml` playbook performs the following tasks:

1. **Clone or Update Repository**:
   - Clones or pulls the latest changes from the Secret Santa Generator repository to `/home/ubuntu/secretsanta-generator`.

2. **Copy and Execute Shell Script**:
   - Copies `docker-condition.sh` to the target host and sets execute permissions.
   - Runs the script to stop and remove any existing `secret-santa` Docker container.

3. **Maven Build and Test**:
   - Executes `mvn compile` to compile the Java application.
   - Runs `mvn test` to execute unit tests.
   - Performs `mvn package` to package the application into a JAR file.

4. **SonarQube Analysis**:
   - Runs the SonarQube scanner to analyze code quality and send results to the SonarQube server.

5. **Docker Image Operations**:
   - Builds a Docker image tagged as `zookl0/santa:latest`.
   - Scans the image for vulnerabilities using Trivy and generates a report (`trivy-image-report.html`).
   - Logs in to Docker Hub using credentials from `credentials.yaml`.
   - Pushes the Docker image to Docker Hub.
   - Deploys the application by running the Docker container as `secret-santa` on port `8080`.

## Accessing the Application

- Once deployed, the Secret Santa Generator application is accessible at `http://<host-ip>:8080`.
- The SonarQube server is available at `http://<host-ip>:9000` for code quality reports.
- The Trivy scan report is saved as `trivy-image-report.html` in the `/home/ubuntu/secretsanta-generator` directory.

## Security Notes

- **Credentials**: Ensure `credentials.yaml` is encrypted with Ansible Vault to protect sensitive information like Docker Hub credentials and SonarQube tokens.
- **SonarQube Token**: Replace the sample token in `credentials.yaml` with a valid token from your SonarQube server.
- **Docker Permissions**: The `ubuntu` user is added to the `docker` group to run Docker commands without `sudo`.

## Troubleshooting

- **Ansible Vault Errors**: Ensure the correct vault password is provided when running `CICD.yaml`.
- **Docker Issues**: Verify Docker is running and the `ubuntu` user has appropriate permissions (`docker` group).
- **SonarQube Connection**: Ensure the SonarQube server is accessible at the specified URL (`http://<host-ip>:9000` or your custom URL).
- **Trivy Scan**: Check the `trivy-image-report.html` for any critical vulnerabilities in the Docker image.

## Contributing

To contribute to this project:
1. Fork the repository: `https://github.com/tajroshith/secretsanta-generator.git`.
2. Make changes and test locally.
3. Submit a pull request with a clear description of the changes.

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/tajroshith/secretsanta-generator/blob/main/LICENSE) file for details.
