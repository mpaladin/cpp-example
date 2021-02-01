#! /bin/bash

set -euo pipefail

if [ "$OS_NAME" = "osx" ] || [ "$OS_NAME" = "macOS" ] || [ "$OS_NAME" = "darwin" ]; then
curl -L -O https://sonarcloud.io/static/cpp/build-wrapper-macosx-x86.zip
unzip build-wrapper-macosx-x86.zip
BWRAPPER=$(pwd)/build-wrapper-macosx-x86/build-wrapper-macosx-x86

curl -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-macosx.zip
unzip sonar-scanner-cli-4.5.0.2216-macosx.zip
SONAR_SCANNER=./sonar-scanner-4.5.0.2216-macosx/bin/sonar-scanner

CFAMILY_THREADS=$(sysctl -n hw.ncpu)
else
curl -L -O https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip
unzip build-wrapper-linux-x86.zip
BWRAPPER=$(pwd)/build-wrapper-linux-x86/build-wrapper-linux-x86-64

curl -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-linux.zip
unzip sonar-scanner-cli-4.5.0.2216-linux.zip
SONAR_SCANNER=./sonar-scanner-4.5.0.2216-linux/bin/sonar-scanner

CFAMILY_THREADS=$(nproc)
fi

mkdir build
pushd build
cmake ..
popd
${BWRAPPER} --out-dir bw-output cmake --build build

curl -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216.zip
unzip sonar-scanner-cli-4.5.0.2216.zip
${SONAR_SCANNER} \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.organization=mpaladin \
  -Dsonar.projectKey=${PROJECT_KEY} \
  -Dsonar.login=${SONAR_TOKEN} \
  -Dsonar.sources=src \
  -Dsonar.cfamily.build-wrapper-output=bw-output \
  -Dsonar.cfamily.cache.enabled=true \
  -Dsonar.cfamily.cache.path=${CFAMILY_CAHE_PATH} \
  -Dsonar.cfamily.threads=${CFAMILY_THREADS}
