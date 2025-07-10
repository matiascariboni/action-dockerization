# 🐳 Dockerization

This GitHub Composite Action automates Docker-related configuration steps in your CI/CD workflows. It is designed to simplify and standardize Docker image tagging, Dockerfile selection, port and network parsing, and image building using `buildx`.

## 🔧 Features

- ✅ Automatically determines the correct Docker tag from Git branches or Git tags
- ✅ Dynamically selects the appropriate `Dockerfile` based on branch name
- ✅ Extracts port mappings and network configuration hints from comments inside `Dockerfile`
- ✅ Uses `docker/setup-qemu-action` and `docker/setup-buildx-action` to support cross-platform builds
- ✅ Builds Docker image using `docker/build-push-action`
- ✅ Outputs useful deployment metadata like image name, Docker tag, Dockerfile path, and more

---

## 📦 Outputs

| Output              | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `DOCKER_TAG`        | Docker tag derived from the Git tag or short commit hash                    |
| `DOCKERFILE_PATH`   | Full path to the Dockerfile used (e.g., `./Dockerfile.master`)              |
| `COMPOSE_FILE_NAME` | Docker Compose filename derived from repo and branch (e.g., `app_master.yml`) |
| `IMAGE_NAME`        | Final Docker image name, e.g., `app_master`                                 |
| `COMPOSE_PORTS`     | Port mappings in `Docker Compose` format, e.g., `80:3000,443:8443`          |
| `COMPOSE_NETWORKS`  | Networks extracted from `# NETWORK ...` comments in the Dockerfile          |

---

## 🚀 How to Use

### 1. Add the Action to Your Workflow

```yaml
jobs:
  dockerization:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run Dockerization composite action
        uses: matiascariboni/action-dockerization@v1.0.1
        id: dockerization
        with:
          IMAGE_ARCH: linux/amd64
