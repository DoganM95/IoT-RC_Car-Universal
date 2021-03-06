#!/bin/bash

# Load configuration file
. ./config.sh

# Definition script functions and vars
Timestamp() {
    date +"%T"
}

currentTime=""

# cd $projectPath
# if [ ! $(git fetch --all) ]; then
#     echo "Run initialize.sh first or clone your repository manually."
#     exit
# fi
git checkout $workingBranch
cd "$sourceCodePath/javascript"
npm install
npm update
killall node && echo "killed any running node process"
killall pigpiod && echo "killed pigpio deamon"
npm start
# echo $(Timestamp) >> "${projectPath}/.../ran.txt"

while true; do
    currentTime=$(Timestamp)
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]; then
        echo $currentTime " - Up-to-date"

    elif [ $LOCAL = $BASE ]; then
        echo $currentTime " - Pulling changes from remote.."
        killall node && echo "killed any running node process"
        killall pigpiod && echo "killed pigpio deamon"
        git reset --hard origin/$workingBranch
        git pull
        chown -R pi $projectPath
        chmod -R +rwx $projectPath
        # sudo npm start &

    elif [ $REMOTE = $BASE ]; then
        echo $currentTime " - Local project folder has changes to push. "
        git reset --hard # origin/$workingBranch # revert changes to be able to pull
        git pull
        # chown -R pi $projectPath
        # chmod -R +rwx $projectPath
        # echo $(Timestamp) "Pushing local changes to remote.."
        # git add $projectPath
        # git commit -m "Automatic push of changes from embedded device"
        # git push

    else
        echo $currentTime " - Diverged"
    fi

    if [ -z "$(ps aux | grep '.*node.*.js' | grep -v '.*grep.*')" ]; then
        echo "webserver stopped, restarting..."
        npm start
        echo "Webserver startet."
    fi
    sleep $sleepDurationBetweenGitFetches
    echo
done
