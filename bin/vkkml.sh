#!/bin/bash
# https://dl.dropboxusercontent.com/u/22223943/vkrep2google.kmz
body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}
tester() {
echo "test script to exercise modules"
    ./bin/vkreptest.pl 
}
usage() {
echo "Usage: $(basename $0) -r repdate [-m][-w][-h][-c][-i][-y][-p][-x][-t]"
echo "  -r  repdate is YYMMDD from wia website"
echo "  -w Get Data from the WIA website"
echo "  -m Get Data from the MARC website"
echo "  -h This help text"
echo "  -c Suppress Chirp Files"
echo "  -i Suppress Icom Files"
echo "  -y Suppress Yaesu Files"
echo "  -d Suppress DMR Files"
echo "  -p Suppress Publish"
echo "  -x Test new function"
echo "  -t Test perl and libraries"

echo "normal full run     -r repdate -w"
echo "e.g. ...../Repeater Directory 160103.csv   -r 160103"
}

mand=
if [ "$1" != "" ]; then
    outicom=0
    outyaesu=0
    outchirp=0
    outdmr=0
    outtest=
    getweb=0
    getmarc=0
    publish=0
    args=$(getopt r:cdhiyptwmx $*)
    if [ $? != 0 ] ; then usage ; exit 0 ; fi

    set -- $args

    for i
    do 
        case "$i"
        in
            -r ) repdate=$2 ; mand=0 ; shift 2 ;;
            -h ) usage ; exit 0 ;;
            -c ) outchirp= ; shift ;;
            -i ) outicom= ; shift ;;
            -y ) outyaesu= ; shift ;;
            -d ) outdmr= ; shift ;;
            -p ) publish= ; shift ;;
            -x ) publish= ; outtest=0 ; shift ;;
            -w ) getweb= ; shift ;;
            -m ) getmarc= ; shift ;;      
            -t ) tester ; exit 0 ; shift ;;
        esac
    done
fi
if [ ! -n "$mand" ] ; then 
   usage 
   exit 0 
fi
#
#exit
#cd ~/Onedrive/wia
if [ ! -d work ] ; then mkdir work ; fi
if [ ! -d output ] ; then mkdir output ; fi
if [ ! -d output/WP ] ; then mkdir output/WP ; fi
if [ ! -n "$getweb" ] ; then 
    echo "Get data from WIA Repeater Directory $repdate.csv save as repdown.dat"
    rm -r work/*
# rm output/*
    cd work
# Get the WIA data
    curl -f -o repdown.dat http://www.wia.org.au/members/repeaters/data/documents/Repeater%20Directory%20$repdate.csv
#echo $wiaget
#exit
    if [ $? != 0 ] ; then echo "File not found Repeater%20Directory%20$repdate.csv" ; echo "Please check wia website" ; exit 0 ; fi 

    tr -d '\r' < repdown.dat > repdowntext.dat
    echo "Generated work/repdownext.dat from repdown.dat remove CR"
    gsed -f ../bin/wiahead2.gsed repdowntext.dat > wiarepdiri.csv
    echo "Generated work/wiarepdiri.csv headings"
    cp wiarepdiri.csv wiarepdir.csv
    
    echo "Local edit of the wiarepdir.csv for repeater changes with wiarepdir.gsed"
    gsed -f ../bin/wiarepdir.gsed wiarepdiri.csv > wiarepdir.csv
    echo "Generated work/wiarepdir.csv local edit"
#
# Get VK2MD file 
    echo "starting get data from vk2md"
    curl -o vkrep2google.zip https://dl.dropboxusercontent.com/u/22223943/vkrep2google.kmz
    unzip vkrep2google.zip
# now get rid of most of the file 
    let i=`awk '/<kml/{ print NR; exit }' vkrep2google.kml`
    let j=`awk '/<Document>/{ print NR; exit }' vkrep2google.kml`+1
    let k=`awk '/<name>Amateur Repeaters/{ print NR; exit }' vkrep2google.kml`-2
    let l=`awk '/kml>/{ print NR; exit }' vkrep2google.kml`
    range=`echo "$i"d\;"$j","$k"d\;"$l"d`
#echo $range
    echo "starting the sed of vkrep2google.kml"
# 
    sed -e $range vkrep2google.kml  > vkrep2work.kml
#
# remove the line feed in the repeater names
    echo "starting the ex of vkrep2work.kml"
    ex -c "%g/name></j" -c "wq" vkrep2work.kml
#
# apply several cleanups 
    echo "starting the sed of vkrep2work.kml vkrep.xml"
#
    sed -f ../bin/2mdkml.sed vkrep2work.kml |xmllint --format - > vkrep.xml
    cd ..
fi    
#    
if [ ! -n "$getmarc" ] ; then 
    echo "starting get data from MARC"
    cd work
# Get DMR contacts
    curl -f -o userdown.dat  --data table=users\&format=csv\&header=1 http://www.dmr-marc.net/cgi-bin/trbo-database/datadump.cgi
    if [ $? != 0 ] ; then echo "Extract Failed" ; echo "Please check dmr-marc website" ; exit 0 ; fi 
    grep "^Radio" userdown.dat |sed 's/<br\/>//' > userwork.dat
    grep "^505" userdown.dat |sed 's/<br\/>//' >> userwork.dat
    grep "^530" userdown.dat |sed 's/<br\/>//' >> userwork.dat
    grep "^537" userdown.dat |sed 's/<br\/>//' >> userwork.dat
#
    cd ..
# here we leave work and this is the end of the section for getting raw data from web
fi
#
# do some distance calculations and tiny amount of additional cleanup
#
echo "starting vkrep3.pl create vkrep.csv extracted data from kml"
    ./bin/vkrep3.pl work/vkrep.xml | sed -f bin/vkrep.sed  |sort > work/vkrep.csv
     gsed -f ./bin/vkrep.gsed work/vkrep.csv > output/vkrep.csv
echo "starting vkrep4.pl create vkrepdir.csv wialist merged with kml and distance"
    ./bin/vkrep4.pl work/wiarepdir.csv output/vkrep.csv|sed -f bin/vkrep.sed  |sort > output/vkrepdir.csv
#
# This is callsign then input frequency
sort --field-separator=',' --key=7,7 --key=5g,5 output/vkrepdir.csv > work/sortvkrepdir.csv
#
# get the local entries file vkrepstd from defaults
cp Defaults/vkrepstd.srccsv output/vkrepstd.csv
if [ -n "$outtest" ] ; then
    echo "Testing a new format generating work/chtemp.csv"
    ./bin/vkrepch.pl work/sortvkrepdir.csv output/vkrepstd.csv work/shinytemp.csv
    ./bin/vkrepshiny.pl work/shinytemp.csv output/s
   # perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/chirpx.csv
    #perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/dmr/scan.csv
    #perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/dmr/zone.csv
    
    echo "generated the test file and sorting on field 1"
# This is callsign then input frequency
#  cat work/vkrepftmerge.csv | body sort --field-separator=',' --key=1,1 > work/svkrepftmerge.csv
#
    exit 0
fi
if [ -n "$outyaesu" ] ;  then 
    echo "starting the create of vkrepftmerge.csv"
# reads vkrepdir and vkrepstd (simplex and other local)
    ./bin/vkrepft.pl work/sortvkrepdir.csv output/vkrepstd.csv work/vkrepftmerge.csv 
# This is callsign then input frequency
  cat work/vkrepftmerge.csv | body sort --field-separator=',' --key=1,1 > work/svkrepftmerge.csv
#
#
#        ./bin/vkrep27wft.pl work/sortvkrepdir.csv work/vkrepstd.csv work/vkrepftmerge.csv 
    echo "starting vkrepft-2dr.pl create of vkrepft-2drrts.csv"
        ./bin/vkrepft-2dr.pl work/svkrepftmerge.csv output/vkrepft-2drrts.csv
    echo "starting vkrepft-1dradms6.pl create of vkrepft-1dradms6.csv"
        ./bin/vkrepft-1dradms6.pl work/svkrepftmerge.csv output/vkrepft-1dradms6.csv
    echo "starting vkrepftm-400dradms7.pl create of vkrepftm-400dra.csv and vkrepftm-400drb.csv"
        ./bin/vkrepftm-400dradms7.pl work/svkrepftmerge.csv output/vkrepftm-400dradms7
    echo "starting vkrepftm-400drrts.pl create of vkrepftm-400drrtsa.csv and vkrepftm-400drrtsb.csv"
        ./bin/vkrepftm-400drrts.pl work/svkrepftmerge.csv output/vkrepftm-400drrts
else
    echo "suppressed yaesu"
fi
if [ -n "$outicom" ] ;  then 
    echo "starting the create of vkrepdsmerge.csv"
# reads vkrepdir and vkrepstd (simplex and other local)
#        ./bin/vkrep27wds.pl work/sortvkrepdir.csv work/vkrepstd.csv work/dstemp.csv
        ./bin/vkrepds.pl work/sortvkrepdir.csv output/vkrepstd.csv work/dstemp.csv
        cat work/dstemp.csv | body sort --field-separator=',' --key=1,1 --key=4,4 > work/vkrepdsmerge.csv 
#        
   echo "starting vkrepicom51xx.pl create of icom*.csv"
        cp Defaults/marinemem400.csv output/icombx.csv
        cp Defaults/icomyour.csv output/
        cp Defaults/icomcall.csv output/
        cp Defaults/g14.csv output/icomg14.csv
        ./bin/vkrepicom51x.pl work/vkrepdsmerge.csv output/icom
else
   echo "suppressed icom"
fi  
if [ -n "$outchirp" ] ;  then 
#    echo "starting the create of merged chtemp.csv"
#    ./bin/vkrepch.pl work/sortvkrepdir.csv output/vkrepstd.csv work/chtemp.csv
   echo "starting vkrepchd.pl create of chirpx.csv"
    ./bin/vkrepchd.pl work/vkrepdsmerge.csv output/ch
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/chirpx.csv

## reads vkrepdir and vkrepstd (simplex and other local)
#        ./bin/vkrep27wch.pl work/sortvkrepdir.csv work/vkrepstd.csv work/chtemp.csv
#        cat work/chtemp.csv | body sort --field-separator=',' --key=3,3 > work/vkrepchmerge.csv 
#    echo "starting vkrepchirp.pl create of vkrepchirp.csv"
#        ./bin/vkrepchirp.pl work/vkrepchmerge.csv $repdate_chirp
else
   echo "suppressed chirp"
fi 
if [ -n "$outdmr" ] ;  then 
    if [  -f work/userwork.dat ] ; then
        echo "starting the create of contact.csv for DMR"
        echo "starting dmrscrape.pl"
        ./bin/dmrscrape.pl work/userwork.dat output/DMR
        perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/contacts.csv
        perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/cont-n0gsg.csv
        perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/motocontacts.csv
    fi    
echo "starting the create of channels, scanlists and zones for DMR"
echo "reading work/sortvkrepdir.csv output/vkrepstd.csv writing work/dmtemp.csv"
   ./bin/vkrepdm.pl work/sortvkrepdir.csv output/vkrepstd.csv work/dmtemp.csv
   
echo " sorting dmtemp.csv svkrepdmmerge"
# This is callsign then input frequency
  cat work/dmtemp.csv | body sort --field-separator=',' --key=1,1 > work/svkrepdmmerge.csv
#
   
   
echo "reading work/svkrepdmmerge.csv writing to DMR "
    ./bin/vkrepmd380u.pl work/svkrepdmmerge.csv output/DMR
echo "files are converted to dos for windows programs"   
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/chan.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/scan.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/zone.csv
else
   echo "suppressed DMR contacts"
fi 
if [ -n "$publish" ] ;  then 
    echo "starting the publish"
    ./bin/publishWP -r $repdate
    ./bin/publish
    ./bin/publishGD
    ./bin/publishS3
else
    echo "suppressed publishing"
fi
