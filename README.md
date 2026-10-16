# DevOps Assignment 3 — CI/CD with GitHub Actions

## Overview

A Bash-based Linux diagnostic application with automated
validation, testing, Docker packaging, and a GitHub Actions
continuous integration pipeline.

The project demonstrates a complete CI workflow without
requiring cloud deployment.

## Project Structure

```text
.
├── README.md
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
└── grade.sh
```

## Requirements

- Linux environment
- Bash
- Git
- Docker Engine
- Docker Compose
- Linux networking utilities
- Network access for installing dependencies and building images

## Application Commands

| Command | Description |
|---------|-------------|
| system-info | Display Linux system information |
| check-host HOST | Resolve and check a hostname or IP |
| check-port HOST PORT | Check TCP port connectivity |
| help | Display usage information |

## Setup

Clone the repository:

```bash
git clone https://github.com/Ecstasywonder/devops-assignment-3-github-actions-ci.git
cd devops-assignment-3-github-actions-ci
```

## Local Usage

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host localhost
./app/app.sh check-port localhost 22
```

The final command requires a service listening on port 22.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Operational failure |
| 2 | Invalid command or input |

## Automated Validation

Run Bash syntax and project structure validation:

```bash
./scripts/lint.sh
```

The lint script checks the required project files and runs
Bash syntax validation.

## Automated Tests

Run the application test suite:

```bash
./tests/test.sh
```

The suite contains 12 tests covering help, system information,
valid host resolution, invalid commands, missing arguments,
invalid hostnames, and TCP port validation.

## Docker

Build the application image:

```bash
docker build -t devops-tool .
```

Run the Dockerized application:

```bash
docker run --rm devops-tool help
docker run --rm devops-tool system-info
```

Run automated Docker build and smoke tests:

```bash
./scripts/build.sh
```

The build script verifies help, system information, invalid
commands, and missing-command handling.

## Docker Compose

Validate the Compose configuration:

```bash
docker compose config
```

Run the application:

```bash
docker compose run --rm diagnostic help
docker compose run --rm diagnostic system-info
```

## GitHub Actions CI Pipeline

The GitHub Actions workflow is defined in:

`.github/workflows/ci.yml`

It runs on:
- push
- pull_request

The workflow contains three sequential jobs:

```text
validate
   |
   v
test
   |
   v
docker
```

### Validate

Runs scripts/lint.sh to check project structure and Bash syntax.

### Test

Runs after validate succeeds and executes tests/test.sh.

### Docker

Runs after test succeeds, validates Docker Compose, builds
the image, and executes container smoke tests.

Job dependencies are enforced using the `needs` keyword.

## CI Failure and Recovery Demonstration

A deliberate Bash syntax error was introduced on the
demo/ci-failure-recovery branch to demonstrate how the
CI pipeline detects invalid application code.

### Failed workflow

Run ID: 38963880892

https://github.com/Ecstasywonder/devops-assignment-3-github-actions-ci/actions/runs/38963880892

Outcome: Failed due to intentionally invalid Bash syntax.

### Successful recovery

The syntax error was removed, the application was retested,
and the repaired code was pushed.

Run ID: 38964144190

https://github.com/Ecstasywonder/devops-assignment-3-github-actions-ci/actions/runs/38964144190

Outcome: Successful.

This demonstrates CI failure detection and recovery.

## Instructor Grading

Execute:

```bash
./grade.sh
```

The grader checks repository structure, Bash syntax,
permissions, application behaviour, workflow configuration,
Docker, testing, and Git history.

## Assumptions and Limitations

- The application is designed for Linux.
- Some network checks require external network access.
- ICMP may be restricted by firewall rules.
- A valid TCP port does not guarantee that a service is listening.
- Container system information may differ from the host.
- GitHub-hosted runners can have different networking environments.
- Docker image builds may require internet access.
- No cloud deployment is required.

## Version Control

Development used feature branches and merge commits.

The CI failure demonstration was performed on a separate
branch and followed by a successful recovery.

## Repository

https://github.com/Ecstasywonder/devops-assignment-3-github-actions-ci
