#!/bin/bash
body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}
tester() {
echo "test script to exercise modules"
    ./bin/dmrtest.pl 
}
usage() {
echo "Usage: $(basename $0) [-h][-c][-i][-y][-p][-x][-w][-t]"
echo "  -w Get Data from the website"
echo "  -h This help text"
echo "  -c Suppress Chirp Files"
echo "  -p Suppress Publish"
echo "  -x Test new function"
echo "  -t Test perl and libraries"

echo "normal full run   $(basename $0)   -w"
}

mand=
if [ "$1" != "" ]; then
    outtest=
    outchirp=0
    getweb=0
    publish=0
    args=$(getopt chptwx $*)
    mand=0 # normally set in a mandatory option 
    if [ $? != 0 ] ; then usage ; exit 0 ; fi

    set -- $args

    for i
    do 
        case "$i"
        in
            -h ) usage ; exit 0 ;;
            -c ) outchirp= ; shift ;;
            -p ) publish= ; shift ;;
            -x ) publish= ; outtest=0 ; shift ;;
            -w ) getweb= ; shift ;;
            -t ) tester ; exit 0 ; shift ;;
        esac
    done
fi
if [ ! -n "$mand" ] ; then 
   usage 
   exit 0 
fi
#cd ~/Onedrive/wia
if [ ! -n "$getweb" ] ; then 
if [ ! -d work ] ; then mkdir work ; fi
if [ ! -d output ] ; then mkdir output ; fi
rm work/*
# rm output/*
cd work
curl -f -o userdown.dat  --data table=users\&format=csv\&header=1 http://www.dmr-marc.net/cgi-bin/trbo-database/datadump.cgi
if [ $? != 0 ] ; then echo "Extract Failed" ; echo "Please check dmr-marc website" ; exit 0 ; fi 
grep "^Radio" userdown.dat > userwork.dat
grep "^505" userdown.dat >> userwork.dat
grep "^530" userdown.dat >> userwork.dat
grep "^537" userdown.dat >> userwork.dat
cd ..
fi
#tr -d '\r' < repdown.dat > repdowntext.dat
#gsed -f ../bin/wiahead2.gsed repdowntext.dat > wiarepdiri.csv
#gsed -f ../bin/wiarepdir.gsed wiarepdiri.csv > wiarepdir.csv
echo "starting scrape.pl"
   ./bin/scrape.pl work/userwork.dat output/contact.csv 
if [ -n "$outtest" ] ; then
    echo "Testing a new format generating work/xxx.csv"
   # ./bin/vkrepft.pl work/sortvkrepdir.csv output/vkrepstd.csv work/vkrepftmerge.csv 
    echo "generated the test file and sorting on field 1"
# This is callsign then input frequency
 # cat work/vkrepftmerge.csv | body sort --field-separator=',' --key=1,1 > work/svkrepftmerge.csv
#
    exit 0
fi
if [ -n "$outchirp" ] ;  then 
    echo "starting the create of vkrepchmerge.csv [coming soon!!]"
## reads vkrepdir and vkrepstd (simplex and other local)
#        ./bin/vkrep27wch.pl work/sortvkrepdir.csv work/vkrepstd.csv work/chtemp.csv
#        cat work/chtemp.csv | body sort --field-separator=',' --key=3,3 > work/vkrepchmerge.csv 
#    echo "starting vkrepchirp.pl create of vkrepchirp.csv"
#        ./bin/vkrepchirp.pl work/vkrepchmerge.csv $repdate_chirp
else
   echo "suppressed chirp"
fi 
if [ -n "$publish" ] ;  then 
    echo "starting the publish"
    ./bin/publish
    ./bin/publishGD
    ./bin/publishS3
else
    echo "suppressed publishing"
fi

