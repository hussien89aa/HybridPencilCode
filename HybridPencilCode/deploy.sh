# Deployment
# ----------

echo Handling node.js grunt deployment.

# 1. Select node version
selectNodeVersion

# 2. Install npm packages
if [ -e "$DEPLOYMENT_SOURCE/package.json" ]; then
  eval $NPM_CMD install
  exitWithMessageOnError "npm failed"
fi

# 3. Install bower packages
if [ -e "$DEPLOYMENT_SOURCE/bower.json" ]; then
  eval $NPM_CMD install bower
  exitWithMessageOnError "installing bower failed"
  ./node_modules/.bin/bower install
  exitWithMessageOnError "bower failed"
fi

# 4. Run grunt
if [ -e "$DEPLOYMENT_SOURCE/Gruntfile.js" ]; then
  eval $NPM_CMD install grunt-cli
  exitWithMessageOnError "installing grunt failed"
  ./node_modules/.bin/grunt --no-color clean common dist
  exitWithMessageOnError "grunt failed"
fi

# 5. KuduSync to Target
"$KUDU_SYNC_CMD" -v 500 -f "$DEPLOYMENT_SOURCE/dist" -t "$DEPLOYMENT_TARGET" -n "$NEXT_MANIFEST_PATH" -p "$PREVIOUS_MANIFEST_PATH" -i ".git;.hg;.deployment;deploy.sh"
exitWithMessageOnError "Kudu Sync to Target failed"