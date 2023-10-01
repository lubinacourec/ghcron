#! /bin/sh -l
absver=0

if [ -z "${GHREPO}" ]; then
  echo 'Please specify a github repo to mirror to ("user/repo")'
  exit 1
fi

if [ ! -z "${ENABLEABSVER}" ] && [ "${ENABLEABSVER}" != "false" ]; then
  echo "Enabling absolute versioning"
  absver=1
fi

git clone "https://github.com/${GHREPO}.git" . || exit 1
git config --global --add safe.directory /github/workspace

# handle absolute version
if [ "$absver" = "1" ]; then
  # calc absolute version, zero pad to 5 digits. RELEASE_VERSION has to be set for RFG.
  RELEASE_VERSION=$(printf "%05d" $(git rev-list --count HEAD))
  VERSION="$RELEASE_VERSION" # might work as override?
  TAG_PRETTY=$(git rev-list --count HEAD)
  echo "using absolute release version #$RELEASE_VERSION"
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
echo ""

#rename jars with absolute version number
#if [ "$absver" = "1" ]; then
#  prename 's/^(.*?)-/$1-'"$RELEASE_VERSION"'-/' *
#fi

#get name for release (uses shortest jar filename)
RELEASENAME=$(find ./build/libs -type f -name "*.jar" | awk '{print length, $0}' | sort -n | head -n 1 | cut -d " " -f 2- | sed 's/\.jar$//' | xargs -I{} basename {})
echo "release = $RELEASENAME"

#create github release with artifacts
gh release create "$TAG_PRETTY" ./build/libs/*.jar --generate-notes --title "$RELEASENAME"
