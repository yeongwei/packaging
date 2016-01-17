#!/bin/bash

##########################
## F U N C T I O N S #####
##########################
function printInfo {
	echo "[INFO] $1";
}

function printUsage {
	echo "Usage: ./`basename "$0"` [WORKING DIRECTORY] [OUTPUT JAR NAME]";
	echo "[WORKING DIRECTORY]: The directory consist of all the required JAR files.";
	echo "[OUTPUT JAR NAME]: The prefered file name for the output JAR.";
}

function die {
	if [ -z $1 ]; then
		echo $1;
	fi
	exit 1;
}

function getJarName {
	if [ -z $1 ]; then
		die "Not enough argument."
	else
		echo ${$1//}
	fi
}

##########################
## C H E C K S ###########
##########################
WORK_DIR=$1;
if [ -z $WORK_DIR ]; then
	WORK_DIR=`pwd`"/";
fi

if [ $WORK_DIR != */ ]; then
	WORK_DIR=$WORK_DIR"/";
fi

OUTPUT_JAR_NAME=$2;
if [ -z $OUTPUT_JAR_NAME ]; then
	OUTPUT_JAR_NAME="tnpmJdbcUber.jar";
fi

OUTPUT_DIR=$WORK_DIR"output/";
TEMP_DIR=$WORK_DIR".temp/";
PACKAGING_DIR=$WORK_DIR".packaging/";
FINAL_JAR=$OUTPUT_DIR$OUTPUT_JAR_NAME;

##########################
## M A I N ###############
##########################
printInfo "Attempting to clean Working Directory.";
rm -rf $TEMP_DIR;
rm -rf $PACKAGING_DIR;
rm -rf $OUTPUT_DIR;

mkdir $OUTPUT_DIR;
mkdir $TEMP_DIR;
mkdir $PACKAGING_DIR;

printInfo "Scanning for JAR files in $WORK_DIR.";
JAR_FILES=(`find $WORK_DIR -name "*.jar"`);
printInfo "Found ${#JAR_FILES[@]} JAR files.";

for fileName in ${JAR_FILES[@]}; do
	fileParts=(${fileName//\// });	# Split file names into segments by /
	lastSegment=${#fileParts[@]};
	lastSegment=$((lastSegment-1));	# Only file name
	subDirectory=$TEMP_DIR${fileParts[lastSegment]}"/";
	printInfo "Creating directory for $subDirectory.";
	mkdir $subDirectory;
	cp $fileName $subDirectory;
	cd $subDirectory;
	printInfo "Extracting $fileName.";
	jar -xf $fileName;
	rm *.jar;	
	cp -rf . $PACKAGING_DIR;
done;

printInfo "Repacking Java Class files.";
jar cf $FINAL_JAR -C $PACKAGING_DIR .;

printInfo "JAR file located at $FINAL_JAR.";
printInfo "Done.";
