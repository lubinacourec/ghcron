#! /bin/sh -l

GHREPO="${1}"
absver=0

if [ -z "${GHREPO}" ]; then
  echo 'Please specify a github repo to mirror to ("user/repo")'
  exit 1
fi

if [ ! -z "${2}" ]; then
  echo "Enabling absolute versioning"
  absver=1
fi

git clone "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GHREPO}.git" . || exit 1

# handle absolute version
if [ "$absver" = "1" ]; then
  # calc absolute version, zero pad to 5 digits. value of VERSION is used by RFG as override.
  VERSION=$(printf "%05d" $(git rev-list --count HEAD))
fi

chmod +x gradlew
#build
./gradlew --build-cache --info --stacktrace setupCIWorkspace
./gradlew --build-cache --info --stacktrace build

#check for server crash
mkdir run
echo "eula=true" > run/eula.txt
echo "level-seed=-6202107849386030209\nonline-mode=true\n" > run/server.properties
echo "stop" > run/stop.txt
timeout 120 ./gradlew --build-cache --info --stacktrace runServer 2>&1 < run/stop.txt | tee -a server.log || true

#check server log for errors
#this is very secure go away
curl -fsSL https://raw.githubusercontent.com/GTNewHorizons/GTNH-Actions-Workflows/master/scripts/test_no_error_reports | bash

#get name for release (uses shortest jar filename)
RELEASENAME=$(find build/libs -type f -name "*.jar" | awk '{print length, $0}' | sort -n | head -n 1 | cut -d " " -f 2- | sed 's/\.jar$//)

#create github release with artifacts
gh api --method POST -H "Accept: application/vnd.github+json" \
            "/repos/${GHREPO}/releases/generate-notes" \
            -f tag_name="${RELEASENAME}" \
            --jq ".body" > tmp_changelog.md
cat tmp_changelog.md
gh release create "${RELEASENAME" -F tmp_changelog.md ./build/libs/*.jar
