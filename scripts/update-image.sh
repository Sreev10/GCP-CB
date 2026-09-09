#!/bin/bash

set -e
IMAGE="us-central1-docker.pkg.dev/${PROJECT_ID}/app-practice-artifact-repo/backend-api:${COMMIT_SHA}"

sed -i "s|image: .*backend-api:.*|image: ${IMAGE}|" k8s/base/deployment.yaml

git config user.name "Cloud Build"
git config user.email "cloud-build@${PROJECT_ID}.iam.gserviceaccount.com"
git add k8s/base/deployment.yaml
git commit -m "ci: update image [skip ci] ${COMMIT_SHA}"|| true
git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/Sreev10/GCP-CB.git"
git branch -M main
git push origin main