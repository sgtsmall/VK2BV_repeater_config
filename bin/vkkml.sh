#!/bin/bash
# This where the data from vk2md used to be
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
  echo "Usage: $(basename $0) -r repdate [-m][-s][-w][-h][-c][-i][-y][-p][-u][-x][-z][-t]"
  echo "  -r  repdate is YYMMDD from wia website"
  echo "  -w Get Data from the WIA website"
  echo "  -s Get Data from the ACMA website"
  echo "  -m Get Data from the MARC website"
  echo "  -h This help text"
  echo "  -c Suppress Chirp Files"
  echo "  -i Suppress Icom Files"
  echo "  -y Suppress Yaesu Files"
  echo "  -d Suppress DMR Files"
  echo "  -p Publish"
  echo "  -u Suppress uhf "
  echo "  -z Include Wicen "
  echo "  -x Test new function"
  echo "  -t Test perl and libraries"

  echo "normal full run  $(basename $0) -r repdate -w -m"
  echo ""
  echo "prepare files for radios then run   $(basename $0) -r repdate -p"
  echo " then edit web page manually"
  echo " need to automate this bit"

  echo "e.g. ...../Repeater Directory 160103.csv   -r 160103"
}

mand=
if [ "$1" != "" ]; then
  outicom=0
  outyaesu=0
  outchirp=0
  outdmr=0
  outuhf=0
  outwic=0
  outtest=
  getweb=0
  getmarc=0
  getspectra=0
  publish=0
  args=$(getopt r:cdhiypstuwmxz $*)
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
      -u ) outuhf= ; shift ;;
      -z ) outwic= ; shift ;;
      -y ) outyaesu= ; shift ;;
      -d ) outdmr= ; shift ;;
      -p ) publish= ; shift ;;
      -x ) publish= ; outtest=0 ; shift ;;
      -w ) getweb= ; shift ;;
      -m ) getmarc= ; shift ;;
      -s ) getspectra= ; mand=0 ; shift ;;
      -t ) tester ; exit 0 ; shift ;;
    esac
  done
fi
if [ ! -n "$mand" ] ; then
  usage
  exit 0
fi
#
here=`pwd`
#exit
#cd ~/Onedrive/wia
if [ ! -d work ] ; then mkdir work ; fi
if [ ! -d archive ] ; then mkdir archive ; fi
if [ ! -d output ] ; then mkdir output ; fi
if [ ! -d output/DMR ] ; then mkdir output/DMR ; fi
if [ ! -d output/YAESU ] ; then mkdir output/YAESU ; fi
if [ ! -d output/ICOM ] ; then mkdir output/ICOM ; fi
if [ ! -d output/WP ] ; then mkdir output/WP ; fi
if [ ! -d output/wicen ] ; then mkdir output/wicen ; fi
if [ ! -d output/wicen/DMR ] ; then mkdir output/wicen/DMR ; fi
if [ ! -d output/wicen/YAESU ] ; then mkdir output/wicen/YAESU ; fi
if [ ! -d output/wicen/ICOM ] ; then mkdir output/wicen/ICOM ; fi
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
  if [ ! -d ../archive/$repdate ] ; then mkdir ../archive/$repdate ; fi
  cp repdown.dat ../archive/$repdate
  tr -d '\r' < repdown.dat > repdowntext.dat
  echo "Generated work/repdownext.dat from repdown.dat remove CR"
  gsed -f ../bin/wiahead2.gsed repdowntext.dat > wiarepdiri.csv
  echo "Generated work/wiarepdiri.csv headings"
  cp wiarepdiri.csv wiarepdir.csv

  echo "Local edit of the wiarepdir.csv for repeater changes with wiarepdir.gsed"
  gsed -f ../bin/wiarepdir.gsed wiarepdiri.csv > wiarepdir.csv
  echo "Generated work/wiarepdir.csv local edit"
  #
  cd ..
fi # end getweb
#
if [ ! -n "$getspectra" ] ; then
  echo "starting get data from spectra"
  cd work
  # Get spectra contacts
  curl -f -o spectra_rrl.zip http://web.acma.gov.au/rrl-updates/spectra_rrl.zip
  if [ $? != 0 ] ; then echo "Extract Failed" ; echo "Please check acma website" ; exit 0 ; fi
  unzip spectra_rrl.zip
  cd ..
  echo "Extracting repeaters location, adding bearing and distance for Bank assignment"
  ./bin/spectra01_dev.pl work/shortdev.csv
  echo "Merge missing data [if you get Key xxx already seen then now dup]"
  sort work/shortdev.csv  Defaults/localshortdev.csv > output/shortsite.csv
fi #end getspectra

if [ ! -n "$getmarc" ] ; then
  echo "starting get data from MARC"
  cd work
  # Get DMR contacts
  curl -f -o userdown.dat  --data table=users\&format=csv\&header=1 http://www.dmr-marc.net/cgi-bin/trbo-database/datadump.cgi
  if [ $? != 0 ] ; then echo "Extract Failed" ; echo "Please check dmr-marc website" ; exit 0 ; fi
  grep "^Radio" userdown.dat |sed 's/<br\/>//' > userwork.dat
  grep "^505" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  #   grep "^530" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  grep "^537" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  #
  cd ..
  # here we leave work and this is the end of the section for getting raw data from web
fi #end getmarc
#
echo "starting vkrep5.pl (5th version!) create vkrepdir.csv wialist merged with acma"
./bin/vkrep5.pl work/wiarepdir.csv output/shortsite.csv|sed -f bin/vkrep.sed  |sort > output/vkrepdir.csv
#
echo "sort vkrepdir.csv to create sortvkrepdir.csv in work and archive"
# This is callsign then input frequency
sort --field-separator=',' --key=7,7 --key=5g,5 output/vkrepdir.csv > work/sortvkrepdir.csv
#
cp work/sortvkrepdir.csv archive/$repdate
# get the local entries file vkrepstd from defaults
cp Defaults/vkrepstd.srccsv output/vkrepstd.csv

if [ ! -n "$outuhf" ] ; then
  echo "adding uhf mar"
  cat Defaults/vkrepuhf.srccsv >> output/vkrepstd.csv
  cat Defaults/vkrepmar.srccsv >> output/vkrepstd.csv
else
  echo "suppressed uhf-mar"
fi

if [ ! -n "$outwic" ] ; then
  echo "adding wicen"
  cat Defaults/vkrepwic.srccsv > output/wicen/vkrepstdw.csv
else
  echo "suppressed wicen"
fi

if [ -n "$outtest" ] ; then
  echo "Testing a new format generating work/shortdev.csv"
  #   ./bin/vkrepch.pl work/sortvkrepdir.csv output/vkrepstd.csv work/shinytemp.csv
  ./bin/spectra01_dev.pl work/shortdev.csv

  sort work/shortdev.csv Defaults/localshortdev.csv > output/shortsite.csv

  echo "generated the test file and sorting on field 1"
  # This is callsign then input frequency
  #
  exit 0
fi
if [ -n "$outyaesu" ] ;  then
  echo "Processing Yaesu Standard"
  echo "starting the create of vkrepftmerge.csv"
  # reads vkrepdir and vkrepstd (simplex and other local)
  ./bin/vkrepft.pl work/sortvkrepdir.csv output/vkrepstd.csv work/vkrepftmerge.csv
  # This is callsign then input frequency
  cat work/vkrepftmerge.csv | body sort --field-separator=',' --key=1,1 > work/svkrepftmerge.csv
  #
  #
  #        ./bin/vkrep27wft.pl work/sortvkrepdir.csv work/vkrepstd.csv work/vkrepftmerge.csv
  echo "starting vkrepft-2dr.pl create of vkrepft-2drrts.csv"
  ./bin/vkrepft-2dr.pl work/svkrepftmerge.csv output/YAESU/vkrepft-2drrts.csv
  echo "starting vkrepft-1dradms6.pl create of vkrepft-1dradms6.csv"
  ./bin/vkrepft-1dradms6.pl work/svkrepftmerge.csv output/YAESU/vkrepft-1dradms6.csv
  echo "starting vkrepftm-400dradms7.pl create of vkrepftm-400dra.csv and vkrepftm-400drb.csv"
  ./bin/vkrepftm-400dradms7.pl work/svkrepftmerge.csv output/YAESU/vkrepftm-400dradms7
  echo "starting vkrepftm-400drrts.pl create of vkrepftm-400drrtsa.csv and vkrepftm-400drrtsb.csv"
  ./bin/vkrepftm-400drrts.pl work/svkrepftmerge.csv output/YAESU/vkrepftm-400drrts
  if [ ! -n "$outwic" ] ; then
    echo "Processing Yaesu Wicen"
    echo "starting the create of vkrepftmerge.csv"
    # reads vkrepdir and vkrepstd (simplex and other local)
    ./bin/vkrepft.pl output/wicen/vkrepstdw.csv Defaults/vkrepblank.srccsv work/vkrepftmergew.csv
    # This is callsign then input frequency
    cat work/vkrepftmergew.csv | body sort --field-separator=',' --key=1,1 > work/svkrepftmergew.csv
    #
    #
    #        ./bin/vkrep27wft.pl work/sortvkrepdir.csv work/vkrepstd.csv work/vkrepftmerge.csv
    echo "starting vkrepft-2dr.pl create of vkrepft-2drrts.csv"
    ./bin/vkrepft-2dr.pl work/svkrepftmergew.csv output/wicen/YAESU/vkrepft-2drrts.csv
    echo "starting vkrepft-1dradms6.pl create of vkrepft-1dradms6.csv"
    ./bin/vkrepft-1dradms6.pl work/svkrepftmergew.csv output/wicen/YAESU/vkrepft-1dradms6.csv
    echo "starting vkrepftm-400dradms7.pl create of vkrepftm-400dra.csv and vkrepftm-400drb.csv"
    ./bin/vkrepftm-400dradms7.pl work/svkrepftmergew.csv output/wicen/YAESU/vkrepftm-400dradms7
    echo "starting vkrepftm-400drrts.pl create of vkrepftm-400drrtsa.csv and vkrepftm-400drrtsb.csv"
    ./bin/vkrepftm-400drrts.pl work/svkrepftmergew.csv output/wicen/YAESU/vkrepftm-400drrts
  fi
else
  echo "suppressed yaesu"
fi
if [ -n "$outicom" ] ;  then
  echo "Processing ICOM Standard"
  echo "starting the create of vkrepdsmerge.csv"
  # reads vkrepdir and vkrepstd (simplex and other local)
  #        ./bin/vkrep27wds.pl work/sortvkrepdir.csv work/vkrepstd.csv work/dstemp.csv
  ./bin/vkrepds.pl work/sortvkrepdir.csv output/vkrepstd.csv work/dstemp.csv
  cat work/dstemp.csv | body sort --field-separator=',' --key=1,1 --key=4,4 > work/vkrepdsmerge.csv
  #
  echo "starting vkrepicom51x.pl create of icom*.csv"
  cp Defaults/marinemem400.csv output/ICOM/icombx.csv
  cp Defaults/icomyour.csv output/ICOM/
  cp Defaults/icomcall.csv output/ICOM/
  cp Defaults/g14.csv output/ICOM/icomg14.csv
  ./bin/vkrepicom51x.pl work/vkrepdsmerge.csv output/ICOM/icom
  if [ ! -n "$outwic" ] ; then
    echo "Processing ICOM Wicen"
    echo "starting the create of vkrepdsmergew.csv"
    # reads vkrepdir and vkrepstd (simplex and other local)
    #        ./bin/vkrep27wds.pl work/sortvkrepdir.csv work/vkrepstd.csv work/dstemp.csv
    ./bin/vkrepds.pl output/wicen/vkrepstdw.csv Defaults/vkrepblank.srccsv work/dstempw.csv
    cat work/dstempw.csv | body sort --field-separator=',' --key=1,1 --key=4,4 > work/vkrepdsmergew.csv
    #
    echo "starting vkrepicom51x.pl create of icom*.csv"
#    cp Defaults/marinemem400.csv output/icombx.csv
#    cp Defaults/icomyour.csv output/
#    cp Defaults/icomcall.csv output/
#    cp Defaults/g14.csv output/icomg14.csv
    ./bin/vkrepicom51x.pl work/vkrepdsmergew.csv output/wicen/ICOM/icom
  fi
  if [ -n "$outchirp" ] ;  then
    #    echo "starting the create of merged chtemp.csv" Chirp dependent on icom
    #    ./bin/vkrepch.pl work/sortvkrepdir.csv output/vkrepstd.csv work/chtemp.csv
    echo "Processing Chirp Standard"
    echo "starting vkrepchd.pl create of chirpx.csv"
    ./bin/vkrepchd.pl work/vkrepdsmerge.csv output/ch
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/chirpx.csv
    cp output/chirpx.csv archive/$repdate
    if [ ! -n "$outwic" ] ; then
      echo "Processing Chirp Wicen"
      echo "starting vkrepchd.pl create of chirpx.csv"
      ./bin/vkrepchd.pl work/vkrepdsmergew.csv output/wicen/ch
      perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/chirpx.csv
  #    cp output/chirpx.csv archive/$repdate
    fi
  else
    echo "suppressed chirp"
  fi

else
  echo "suppressed icom and chirp"
fi
if [ -n "$outdmr" ] ;  then
  echo "Processing DMR Standard"
  if [  -f work/userwork.dat ] ; then
    echo "starting the create of contact.csv for DMR"
    echo "starting dmrscrape.pl"
    ./bin/dmrscrape.pl work/userwork.dat output/DMR
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/contacts.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/cont-n0gsg.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/motocontacts.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt82contacts.csv
  fi
  echo "starting the create of channels, scanlists and zones for DMR"
  echo "reading work/sortvkrepdir.csv output/vkrepstd.csv writing work/dmtemp.csv"
  ./bin/vkrepdm.pl work/sortvkrepdir.csv output/vkrepstd.csv work/dmtemp.csv

  echo " sorting dmtemp.csv svkrepdmmerge"
  # This is callsign then input frequency
  cat work/dmtemp.csv | body sort --field-separator=',' --key=1,1 > work/svkrepdmmerge.csv
  #

  echo "vkremmd380u.pl reading work/svkrepdmmerge.csv writing to DMR 380"
  ./bin/vkrepmd380u.pl work/svkrepdmmerge.csv output/DMR
  echo "reduce zone entries"
  gsed -f bin/md380zone.gsed output/DMR/rt3uzone.csv > output/DMR/rt3uzonex.csv
  echo "files are converted to dos for windows programs"
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uchan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uscan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uzonex.csv

  echo "vkreprt8vhfg.pl reading work/svkrepdmmerge.csv writing to DMR RT8V G"
  ./bin/vkreprt8vhfg.pl work/svkrepdmmerge.csv output/DMR
  echo "files are converted to dos for windows programs"
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vchan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vscan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vzone.csv

  echo "Merging files for md2017"

  cat output/DMR/rt3uchan.csv > output/DMR/rt82chan.csv
  tail -n +2 output/DMR/rt8vchan.csv >> output/DMR/rt82chan.csv

  cat output/DMR/rt3uscan.csv > output/DMR/rt82scan.csv
  tail -n +2 output/DMR/rt8vscan.csv >> output/DMR/rt82scan.csv

  cat output/DMR/rt3uzonex.csv > output/DMR/rt82zone.csv
  tail -n +2 output/DMR/rt8vzone.csv >> output/DMR/rt82zone.csv
  if [ ! -n "$outwic" ] ; then
    echo "Processing DMR Wicen"
    echo "starting the create of channels, scanlists and zones for DMR"
    echo "reading work/sortvkrepdir.csv output/vkrepstd.csv writing work/dmtemp.csv"
    ./bin/vkrepdm.pl output/wicen/vkrepstdw.csv Defaults/vkrepblank.srccsv work/dmtempw.csv
    echo " sorting dmtempw.csv svkrepdmmergew"
    # This is callsign then input frequency
    cat work/dmtempw.csv | body sort --field-separator=',' --key=1,1 > work/svkrepdmmergew.csv
    #

    echo "vkremmd380u.pl reading work/svkrepdmmergew.csv writing to DMR 380"
    ./bin/vkrepmd380u.pl work/svkrepdmmergew.csv output/wicen/DMR
    echo "reduce zone entries"
#    gsed -f bin/md380zone.gsed output/DMR/rt3uzone.csv > output/DMR/rt3uzonex.csv
#    echo "files are converted to dos for windows programs"
#    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uchan.csv
#    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uscan.csv
#    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uzonex.csv

    echo "vkreprt8vhfg.pl reading work/svkrepdmmergew.csv writing to DMR RT8V G"
    ./bin/vkreprt8vhfg.pl work/svkrepdmmergew.csv output/wicen/DMR
#    echo "files are converted to dos for windows programs"
#    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vchan.csv
#    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vscan.csv
#    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vzone.csv

    echo "Merging files for md2017"

    cat output/wicen/DMR/rt3uchan.csv > output/wicen/DMR/rt82chan.csv
    tail -n +2 output/wicen/DMR/rt8vchan.csv >> output/wicen/DMR/rt82chan.csv

    cat output/wicen/DMR/rt3uscan.csv > output/wicen/DMR/rt82scan.csv
    tail -n +2 output/wicen/DMR/rt8vscan.csv >> output/wicen/DMR/rt82scan.csv

    cat output/wicen/DMR/rt3uzone.csv > output/wicen/DMR/rt82zone.csv
    tail -n +2 output/wicen/DMR/rt8vzone.csv >> output/wicen/DMR/rt82zone.csv
  fi
else
  echo "suppressed DMR contacts"
fi
if [ ! -n "$publish" ] ;  then
  echo "starting the publish WP files"
  ./bin/publishWP.sh -r $repdate
  echo "starting the publish radio rsync and zip"
  ./bin/publish.sh
  echo "starting the publish GoogleDocs files"
  ./bin/publishGD.sh
  echo "starting the publish S3 files"
  ./bin/publishS3.sh
else
  echo "suppressed publishing"
fi
