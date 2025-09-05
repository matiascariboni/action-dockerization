# 🚀 Dockerization GitHub Action

This composite GitHub Action simplifies and automates the Dockerization process for your CI/CD workflows. It dynamically determines the Docker image tag, selects the appropriate Dockerfile, formats ports and networks for Docker Compose, and builds your image using Buildx with support for multiple architectures.

---

## 🔧 What It Does

This action performs the following tasks:

1. **Detects whether the push is a tag or a branch**\
   → If it's a tag: uses the tag name as Docker tag.\
   → If it's a branch: uses the short commit hash as Docker tag.

2. **Resolves the appropriate Dockerfile** based on environment name:

   - If a file named `Dockerfile.<environment>` exists (e.g., `Dockerfile.dev`), it uses that.
   - Otherwise, it falls back to the default `Dockerfile`.

3. **Generates the Docker Compose file name** using the repository name and environment.

4. **Extracts and formats ports** from the Dockerfile for Compose using custom comment syntax like:

   ```Dockerfile
   EXPOSE 3000
   # TO 80
   ```

   ➤ This will map `3000` to `80` in Compose.

5. **Parses networks** from comments like:

   ```Dockerfile
   # NETWORK my-network
   ```

6. **Builds the Docker image** with `buildx`, using the correct tag, Dockerfile, and platform(s).

---

## 📁 Required Files in Your Repository

Your repository must contain:

- ✅ A `Dockerfile` (default) **or** a `Dockerfile.<env_name>` matching the current Git ref.
- ✅ A valid Git structure to differentiate between environments and tags.
- 🔄 You don't need to include any Compose file — the filename is only generated and exposed as output in case it's useful in later workflow steps (e.g., for deployment scripts).

---

## 📦 Inputs

| Name         | Description                                             | Required |
| ------------ | ------------------------------------------------------- | -------- |
| `IMAGE_ARCH` | Platform target for Docker Buildx (e.g., `linux/amd64`) | ✅ Yes    |

---

## 📤 Outputs

| Output name         | Description                                      |
| ------------------- | ------------------------------------------------ |
| `DOCKER_TAG`        | Docker image tag used (from tag or commit hash)  |
| `DOCKERFILE_PATH`   | Path to the Dockerfile used                      |
| `COMPOSE_FILE_NAME` | Compose file name generated from repo and env |
| `IMAGE_NAME`        | Full image name in the format `<repo>_<env>`  |
| `COMPOSE_PORTS`     | Comma-separated port mappings from Dockerfile    |
| `COMPOSE_NETWORKS`  | Comma-separated list of network names            |

---

## 🧪 Example Usage

```yaml
jobs:
  dockerize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dockerization
        id: dockerization
        uses: matiascariboni/action-dockerization@v1.0.1
        with:
          IMAGE_ARCH: linux/amd64

      - name: Print results
        run: |
          echo "Image: ${{ steps.dockerization.outputs.IMAGE_NAME }}"
          echo "Tag: ${{ steps.dockerization.outputs.DOCKER_TAG }}"
          echo "Dockerfile: ${{ steps.dockerization.outputs.DOCKERFILE_PATH }}"
          echo "Compose file: ${{ steps.dockerization.outputs.COMPOSE_FILE_NAME }}"
```

---

❤️ Made with love by Matias Cariboni

