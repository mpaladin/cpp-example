#! /bin/bash

set -euo pipefail

if [ "$TRAVIS_OS_NAME" = "osx" ]; then
curl -L -O https://sonarcloud.io/static/cpp/build-wrapper-macosx-x86.zip
unzip build-wrapper-macosx-x86.zip
BWRAPPER=$(pwd)/build-wrapper-macosx-x86/build-wrapper-macosx-x86
else
curl -L -O https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip
unzip build-wrapper-linux-x86.zip
BWRAPPER=$(pwd)/build-wrapper-linux-x86/build-wrapper-linux-x86-64
fi

mkdir build
pushd build
cmake ..
popd
${BWRAPPER} --out-dir bw-output cmake --build build

curl -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216.zip
unzip sonar-scanner-cli-4.5.0.2216.zip
./sonar-scanner-4.5.0.2216/bin/sonar-scanner \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.organization=mpaladin \
  -Dsonar.projectKey=cpp-example-cmake-travis-$TRAVIS_OS_NAME \
  -Dsonar.login=${SONAR_TOKEN} \
  -Dsonar.sources=src \
  -Dsonar.cfamily.build-wrapper-output=bw-output \
  -Dsonar.cfamily.cache.enabled=true \
  -Dsonar.cfamily.cache.path=${TRAVIS_HOME}/.cfamily \
  -Dsonar.cfamily.threads=$(nproc)
