#!/bin/sh

# compiles the sketch player and moves it into the right directory
# use like this:
# sh ./build.sh

rm warningsAndErrors.txt
rm errors.txt
rm processing.swf
../../flex_sdk_4/bin/mxmlc $OPTS processing.as 2> ./warningsAndErrors.txt
if [ -f processing.swf ]
then
mv processing.swf ../sketchPatchLiveEnv/sketchPlayer/sandbox_files/
echo processing.swf file was created and moved
else
echo 
echo errors:
echo
grep -w -A 3 Error: ./warningsAndErrors.txt
echo
echo ///////////////////////////////////////
fi