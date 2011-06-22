#!/bin/bash

# Create a tag for all git repositories

initializeWorkingDirAndScriptDir() {
    # Set working directory and remove all symbolic links
    workingDir=`pwd -P`

    # Go the script directory
    cd `dirname $0`
    # If the file itself is a symbolic link (ignoring parent directory links), then follow that link recursively
    # Note that scriptDir=`pwd -P` does not do that and cannot cope with a link directly to the file
    scriptFileBasename=`basename $0`
    while [ -L "$scriptFileBasename" ] ; do
        scriptFileBasename=`readlink $scriptFileBasename` # Follow the link
        cd `dirname $scriptFileBasename`
        scriptFileBasename=`basename $scriptFileBasename`
    done
    # Set script directory and remove other symbolic links (parent directory links)
    scriptDir=`pwd -P`
}
initializeWorkingDirAndScriptDir

if [ $# != 2 ] ; then
    echo
    echo "Usage:"
    echo "  $0 droolsReleaseTagName jbpmReleaseTagName"
    echo "For example:"
    echo "  $0 5.2.0.Final 5.1.0.Final"
    echo
    exit 1
fi

echo "The drools, guvnor, ... release tag name is $1"
echo "The jbpm release tag name is $2"
echo -n "Is this ok? (Hit control-c if is not): "
read ok

startDateTime=`date +%s`

droolsjbpmOrganizationDir="$scriptDir/../../.."
cd $droolsjbpmOrganizationDir

for repository in `cat ${scriptDir}/../repository-list.txt` ; do
    echo
    if [ -d $droolsjbpmOrganizationDir/$repository ] ; then
        echo "==============================================================================="
        echo "Repository: $repository"
        echo "==============================================================================="
        cd $repository
        releaseTagName=$1
        if [ $repository = 'jbpm' ]; then
            releaseTagName=$2
        fi
        git push origin $releaseTagName
        gitReturnCode=$?
        cd ..
        if [ $gitReturnCode != 0 ] ; then
            exit $gitReturnCode
        fi
    else
        echo "==============================================================================="
        echo "Missing Repository: $repository. Skipping"
        echo "==============================================================================="
    fi
done

endDateTime=`date +%s`
spentSeconds=`expr $endDateTime - $startDateTime`

echo
echo "Total time: ${spentSeconds}s"
