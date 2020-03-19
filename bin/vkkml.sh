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
  echo "  -u Include uhf "
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
if [ ! -d work/wicen ] ; then mkdir work/wicen ; fi
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
  mkdir wicen
  # Get the WIA data
  curl -f -o repdown.dat http://www.wia.org.au/members/repeaters/data/documents/Repeater%20Directory%20$repdate.csv
  #echo $wiaget
  #exit
  if [ $? != 0 ] ; then echo "File not found Repeater%20Directory%20$repdate.csv" ; echo "Please check wia website" ; exit 0 ; fi
  if [ ! -d ../archive/$repdate ] ; then mkdir ../archive/$repdate ; fi
  cp repdown.dat ../archive/$repdate
  tr -d '\r' < repdown.dat > repdowntext.dat
  echo "Generated work/repdownext.dat from repdown.dat remove CR"
  headgsedscript=wiahead2.gsed
  if [ $repdate > "180317" ] ; then headgsedscript=wiahead3.gsed ; fi
  echo "repdate $repdate headgsedscript $headgsedscript "
  gsed -f ../bin/$headgsedscript repdowntext.dat > wiarepdiri.csv ;

  echo "Generated work/wiarepdiri.csv headings"
  if [ $repdate > "180317" ] ; then ../bin/prune-columnsc.pl wiarepdiri.csv "Latitude" "Longitude" > wiarepdirll.csv ;
else cp wiarepdiri.csv wiarepdirll.csv ; fi

  cp wiarepdirll.csv wiarepdir.csv

  echo "Local edit of the wiarepdir.csv for repeater changes with wiarepdir.gsed"
  gsed -f ../bin/wiarepdir.gsed wiarepdirll.csv > wiarepdir.csv
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
#  curl -f -o userdown.dat  --data table=users\&format=csv\&header=1 http://www.dmr-marc.net/cgi-bin/trbo-database/datadump.cgi

#  curl -f -o userdown.dat https://www.radioid.net/static/users.csv
#  curl -f -o userdown.dat https://ham-digital.org/status/dmrid.dat
  curl -f -o userdown.dat https://www.radioid.net/static/user.csv
  if [ $? != 0 ] ; then echo "Extract Failed" ; echo "Please check radioid.net website" ; exit 0 ; fi
  echo "Radio ID,Callsign,FirstName,LastName,City,State,Country,Remarks" > userwork.dat
  echo "Radio ID,Callsign,FirstName,LastName,City,State,Country,Remarks" > userworka.dat
#  grep "^Radio" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  grep "^505" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  #   grep "^530" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  grep "^537" userdown.dat |sed 's/<br\/>//' >> userwork.dat
  #
  tail -n +2 userdown.dat >> userworka.dat

  echo "Local edit of the userwork.dat for bad user data from marc"
  gsed -ibak -f ../bin/userwork.gsed userwork.dat
  gsed -ibak -f ../bin/userwork.gsed userworka.dat
  cd ..
  # here we leave work and this is the end of the section for getting raw data from web
fi #end getmarc
##
#echo "installing updated My files to library folder"
#sudo cp lib/Favourites.pm /opt/local/lib/perl5/site_perl/5.26/My/Favourites.pm
#cp My/Vkrepsort.pm /opt/local/lib/perl5/site_perl/5.26/My/Vkrepsort.pm

echo "starting vkrep5.pl (5th version!) create vkrepdir.csv wialist merged with acma"
perl ./bin/vkrep5.pl work/wiarepdir.csv output/shortsite.csv|sed -f bin/vkrep.sed  |sort > output/vkrepdir.csv
value=$( cat output/vkrepdir.csv | wc -l )
if [ $value -lt 1 ] ; then
   echo "vkrep5 acma merge failed "
   exit
fi
#if [ $repdate > "180317" ] ; then ./bin/prune-columns.pl work/vkrepdir.csv "Latitude" "Longitude" > output/vkrepdir.csv ;
#else cp work/vkrepdir.csv output/vkrepdir.csv ; fi
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
  echo "starting vkrepft.pl create of vkrepftmerge.csv"
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
if [  -f work/userwork.dat ] ; then
  echo "starting the create of contact.csv for DMR"
  echo "starting dmrscrape.pl"
  ./bin/dmrscrape.pl work/userwork.dat output/DMR
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/contacts.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/cont-n0gsg.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/motocontacts.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt82contacts.csv

  cp work/userdown.dat output/DMR/rt82con10k.csv
fi
if [  -f work/userworka.dat ] ; then
  echo "starting the create of 868contact.csv for 868"
  ./bin/dmrscrape868.pl work/userworka.dat output/DMR
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/868contacts.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/868rxgroup.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/868tgroup.csv
fi
if [ -n "$outdmr" ] ;  then
  echo "Processing DMR Standard"
  echo "starting the create of channels, scanlists and zones for DMR"
  echo "reading work/sortvkrepdir.csv output/vkrepstd.csv writing work/dmtemp.csv"
  ./bin/vkrepdm.pl work/sortvkrepdir.csv output/vkrepstd.csv work/dmtemp.csv

  echo " sorting dmtemp.csv svkrepdmmerge"
  # This is callsign then input frequency
  cat work/dmtemp.csv | body sort --field-separator=',' --key=1,1 > work/svkrepdmmerge.csv
  #

  echo "vkreprt82.pl reading work/svkrepdmmerge.csv writing to DMR RT3 U"
  ./bin/vkreprt82.pl work/svkrepdmmerge.csv output/DMR/ rt3 u

#  echo "reduce zone entries"
#  gsed -f bin/md380zone.gsed output/DMR/rt3uzone.csv > output/DMR/rt3uzonex.csv
  echo "files are converted to dos for windows programs"
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uchan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uscan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt3uzone.csv

  if [ ! -d output/DMR/rt3 ] ; then mkdir output/DMR/rt3 ; fi

  cp output/DMR/cont-n0gsg.csv output/DMR/rt3/

  mv output/DMR/rt3uchan.csv output/DMR/rt3/
  cp output/DMR/rt3uchann0gsg.csv output/DMR/rt3/
  cp output/DMR/rt3uscan.csv output/DMR/rt3/
  cp output/DMR/rt3uzone.csv output/DMR/rt3/


  echo "vkreprt82.pl reading work/svkrepdmmerge.csv writing to DMR RT82 U"
  ./bin/vkreprt82.pl work/svkrepdmmerge.csv work/ rt82 u
  echo "vkreprt868.pl reading work/svkrepdmmerge.csv writing to DMR 868 U"
  ./bin/vkreprt868.pl work/svkrepdmmerge.csv work/ 868 u
#  echo "vkreprt82uprune scan to 32"
#  bin/prune-columns.pl work/rt82uscan.csv Ch32 Ch33 Ch34 Ch35 Ch36 Ch37 Ch38 Ch39 Ch40 Ch41 Ch42 Ch43 Ch44 Ch45 Ch46 Ch47 Ch48 Ch49 Ch50 Ch51 Ch52 Ch53 Ch54 Ch55 Ch56 Ch57 Ch58 Ch59 Ch60 Ch61 Ch62 Ch63 Ch64> work/rt82uxscan.csv

#  echo "reduce zone entries"
  echo "vkreprt82.pl reading work/svkrepdmmerge.csv writing to DMR RT8 V"
  ./bin/vkreprt82.pl work/svkrepdmmerge.csv output/DMR/ rt8 v
  echo "files are converted to dos for windows programs"
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vchan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vscan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt8vzone.csv

  if [ ! -d output/DMR/rt8 ] ; then mkdir output/DMR/rt8 ; fi
  #rsync Defaults/Defrt82/ output/DMR/rt82/
  #cp output/DMR/rt82tgroup.csv output/DMR/rt82/
  #cp output/DMR/rt82rxgroup.csv output/DMR/rt82/
  #cp output/DMR/rt3contacts.csv output/DMR/rt82/
  #cp output/DMR/rt82con10k.csv output/DMR/rt82/
  cp output/DMR/cont-n0gsg.csv output/DMR/rt8/

  mv output/DMR/rt8vchan.csv output/DMR/rt8/
  mv output/DMR/rt8vchann0gsg.csv output/DMR/rt8/
  mv output/DMR/rt8vscan.csv output/DMR/rt8/
  mv output/DMR/rt8vzone.csv output/DMR/rt8/


  echo "vkreprt82.pl reading work/svkrepdmmerge.csv writing to DMR RT82 V"
  ./bin/vkreprt82.pl work/svkrepdmmerge.csv work/ rt82 v
  echo "vkreprt868.pl reading work/svkrepdmmerge.csv writing to DMR 868 V"
  ./bin/vkreprt868.pl work/svkrepdmmerge.csv work/ 868 v
#  echo "vkreprt82vprune scan to 32"
#  bin/prune-columns.pl work/rt82vscan.csv Ch32 Ch33 Ch34 Ch35 Ch36 Ch37 Ch38 Ch39 Ch40 Ch41 Ch42 Ch43 Ch44 Ch45 Ch46 Ch47 Ch48 Ch49 Ch50 Ch51 Ch52 Ch53 Ch54 Ch55 Ch56 Ch57 Ch58 Ch59 Ch60 Ch61 Ch62 Ch63 Ch64> work/rt82vxscan.csv

  echo "Merging files for rt82/md2017"
  echo " Merge channels rt82 DL5"
  cat work/rt82uchan.csv > work/rt82chan.csv
  tail -n +2 work/rt82vchan.csv >> work/rt82chan.csv
  echo " Merge channels rt82 N0GSG"
  cat work/rt82uchann0gsg.csv > work/rt82chann0gsg.csv
  cat work/rt82vchann0gsg.csv >> work/rt82chann0gsg.csv

  sort --field-separator=',' -s --key=1,1 work/rt82chan.csv | cut -c3-  > output/DMR/brt82chan.csv
  sort --field-separator=',' -s --key=1,1 work/rt82chann0gsg.csv| cut -c3-  > output/DMR/brt82chann0gsg.csv



  echo " Merge scanlist"
  cat work/rt82uscan.csv > work/rt82newscan.csv
  tail -n +2 work/rt82vscan.csv >> work/rt82newscan.csv
  gsed -f bin/emptyrt82scan.gsed work/rt82newscan.csv > work/rt82xscan.csv
  awk -F";" '!_[$1]++' work/rt82xscan.csv > output/DMR/rt82scan.csv
  echo " Non uniq rt82 scan entries "
  diff work/rt82xscan.csv output/DMR/rt82scan.csv
  echo " End Non uniq scan entries "
#  awk -F";" '!_[$1]++' work/rt82newscan.csv > output/DMR/rt82scan.csv
#  echo " Non uniq rt82 scan entries "
#  diff work/rt82newscan.csv output/DMR/rt82scan.csv
#  echo " End Non uniq scan entries "
  echo "remove blank zones"
  gsed -f bin/emptyrt82.gsed -f bin/vhfuhf82.gsed work/rt82uzone.csv > work/rt82uxzone.csv
#  tail -n +2 output/DMR/rt8vzone.csv | gsed -f bin/emptyrt82.gsed -f bin/vhfuhf82.gsed  > work/rt82vzone.csv
  gsed -f bin/emptyrt82.gsed -f bin/vhfuhf82.gsed work/rt82vzone.csv  > work/rt82vxzone.csv
  echo " create rt82new_fh.csv merges uhf and vhf with blanks"
  ./bin/vkrepdzones.pl work/rt82uxzone.csv work/rt82vxzone.csv work/rt82
# need to add single channels
  echo " update empty set of new_hf "
  gsed -f bin/emptyurt82.gsed work/rt82newuhf.csv > output/DMR/rt82uzone.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt82uzone.csv
  gsed -f bin/emptyvrt82.gsed work/rt82newvhf.csv > output/DMR/rt82vzone.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/rt82vzone.csv

  if [ ! -d output/DMR/rt82 ] ; then mkdir output/DMR/rt82 ; fi
  cp output/DMR/rt82contacts.csv output/DMR/rt82/
  cp output/DMR/rt82con10k.csv output/DMR/rt82/
  cp output/DMR/cont-n0gsg.csv output/DMR/rt82/

  cp output/DMR/brt82chan.csv output/DMR/rt82/
  cp output/DMR/brt82chann0gsg.csv output/DMR/rt82/
  cp output/DMR/rt82scan.csv output/DMR/rt82/
  mv output/DMR/rt82uzone.csv output/DMR/rt82/
  mv output/DMR/rt82vzone.csv output/DMR/rt82/

  echo "Merging files for Anytone"

  echo " Merge channels 868"
  tail -n +2 work/868uchan.csv > work/868chan.csv
  tail -n +2 work/868vchan.csv >> work/868chan.csv

  echo '"No.","Channel Name","Receive Frequency","Transmit Frequency","Channel Type","Transmit Power","Band Width","CTCSS/DCS Decode","CTCSS/DCS Encode","Contact","Contact Call Type","Radio ID","Busy Lock/TX Permit","Squelch Mode","Optional Signal","DTMF ID","2Tone ID","5Tone ID","PTT ID","Color Code","Slot","Scan List","Receive Group List","TX Prohibit","Reverse","Simplex TDMA","TDMA Adaptive","AES Digital Encryption","Digital Encryption","Call Confirmation","Talk Around","Work Alone","Custom CTCSS","2TONE Decode","Ranging","Through Mode","Digi APRS RX","Analog APRS PTT Mode","Digital APRS PTT Mode","APRS Report Type","Digital APRS Report Channel","Correct Frequency[Hz]","SMS Confirmation","Exclude channel from roaming"' > output/DMR/b868chan.csv

  sort --field-separator=',' -s --key=1,1 work/868chan.csv| cut -c3-  | awk '{print "\"" ++C "\",", $0 }' >> output/DMR/b868chan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/b868chan.csv

  #| awk '{print "\"" ++C "\"", $0 }'

  echo " Merge channels 868 N0GSG"
  cat work/868uchann0gsg.csv > work/868chann0gsg.csv
  cat work/868vchann0gsg.csv >> work/868chann0gsg.csv
  sort --field-separator=',' -s --key=1,1 work/868chann0gsg.csv|cut -c2- > output/DMR/868chann0gsg.csv


  cat work/868uscan.csv > work/868scan.csv
  cat work/868vscan.csv >> work/868scan.csv
#  sort by first field (A,B) to split FM from Dmr
#  cut off the sort field,
# compare field 1(scan name) and 2(first chan) - if there are channels they will be different
#  add a sequence number

  echo '"No.","Scan List Name","Scan Channel Member","Scan Mode","Priority Channel Select","Priority Channel 1","Priority Channel 2","Revert Channel","Look Back Time A[s]","Look Back Time B[s]","Dropout Delay Time[s]","Dwell Time[s]"' > output/DMR/b868scan.csv
  sort --field-separator=',' -s --key=1,1 work/868scan.csv| cut -c3- | awk -F"," '$1 !~ $2{print}'  | awk '{print "\"" ++C "\",", $0 }' >> output/DMR/b868scan.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/b868scan.csv

  cat work/868uzone.csv > work/868zone.csv
  cat work/868vzone.csv >> work/868zone.csv
  echo '"No.","Zone Name","Zone Channel Member","A Channel","B Channel"' > output/DMR/b868zone.csv
  #  sort by first field (A,B) to split FM from Dmr
  #  cut off the sort field,
  # zonemerge 1 will try to combine channels from Uhf (xxx7) and vhf (xxx2) together
  # sed fixes the combined strings
  # zonemerge2 outputs the string with fiest 2 as channel A, B.
  # compare field 2(1st TG) and 3(2ng TG) - For now drop zones that only have 1 entry.
  #  add a sequence number

  sort --field-separator=',' -s --key=1,1 work/868zone.csv| cut -c3-  | awk -f bin/zonemerge.awk | sed 's/" "/\|/' | awk -f bin/zonemerge2.awk | awk -F"," '$2 !~ $3{print}'| awk '{print "\"" ++C "\",", $0 }'  >> output/DMR/b868zone.csv
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/b868zone.csv
  if [ ! -d output/DMR/868 ] ; then mkdir output/DMR/868 ; fi
  rsync Defaults/Def878/* output/DMR/868/
  cp output/DMR/868tgroup.csv output/DMR/868/
  cp output/DMR/868rxgroup.csv output/DMR/868/
  cp output/DMR/868contacts.csv output/DMR/868/
  cp output/DMR/cont-n0gsg.csv output/DMR/868/
  mv output/DMR/b868chan.csv output/DMR/868/
  cp output/DMR/868chann0gsg.csv output/DMR/868/
  mv output/DMR/b868scan.csv output/DMR/868/
  mv output/DMR/b868zone.csv output/DMR/868/
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/868/BV878.LST
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/868/RoamingChannel.CSV
  perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/DMR/868/RoamingZone.CSV





  echo "finished standard DMR"
  if [ ! -n "$outwic" ] ; then
    echo "Processing DMR Wicen"
    echo "starting the create of channels, scanlists and zones for DMR"
    echo "reading work/sortvkrepdir.csv output/vkrepstdw.csv writing work/dmtempw.csv"
    ./bin/vkrepdm.pl output/wicen/vkrepstdw.csv Defaults/vkrepblank.srccsv work/dmtempw.csv
    echo " sorting dmtempw.csv svkrepdmmergew"
    # This is callsign then input frequency
    cat work/dmtempw.csv | sort --field-separator=',' -k1,1 -k2,2 -k3,3 -k17.3,17.6 > work/svkrepdmmergew.csv
    #

    echo "vkreprt82.pl reading work/svkrepdmmergew.csv writing to RT3 U"
    ./bin/vkreprt82.pl work/svkrepdmmergew.csv output/wicen/DMR/ rt3 u
  #  echo "reduce zone entries"
    echo "vkreprt82.pl reading work/svkrepdmmergew.csv writing to DMR RT82 U"
    ./bin/vkreprt82.pl work/svkrepdmmergew.csv work/wicen/ rt82 u
    echo "vkreprt868.pl reading work/svkrepdmmergew.csv writing to DMR 868 U"
    ./bin/vkreprt868.pl work/svkrepdmmergew.csv work/wicen/ 868 u

    echo "vkreprt82.pl reading work/svkrepdmmergew.csv writing to DMR RT8 V"
    ./bin/vkreprt82.pl work/svkrepdmmergew.csv output/wicen/DMR/ rt8 v

    echo "vkreprt82.pl reading work/svkrepdmmergew.csv writing to DMR RT82 V"
    ./bin/vkreprt82.pl work/svkrepdmmergew.csv work/wicen/  rt82 v

    echo "vkreprt868.pl reading work/svkrepdmmergew.csv writing to DMR 868 V"
    ./bin/vkreprt868.pl work/svkrepdmmergew.csv work/wicen/ 868 v

    echo "Merging files for md2017"
    echo " Merge channels rt82 DL5"
    cat work/wicen/rt82uchan.csv > work/wicen/rt82chan.csv
    tail -n +2 work/wicen/rt82vchan.csv >> work/wicen/rt82chan.csv
    echo " Merge channels rt82 N0GSG"
    cat work/wicen/rt82uchann0gsg.csv > work/wicen/rt82chann0gsg.csv
    cat work/wicen/rt82vchann0gsg.csv >> work/wicen/rt82chann0gsg.csv

    sort --field-separator=',' -s --key=1,1 work/wicen/rt82chan.csv | cut -c3-  > output/wicen/DMR/rt82chan.csv
    sort --field-separator=',' -s --key=1,1 work/wicen/rt82chann0gsg.csv| cut -c3-  > output/wicen/DMR/rt82chann0gsg.csv

    echo " Merge scanlist rt82"
    cat work/wicen/rt82uscan.csv > work/wicen/rt82newscan.csv
    tail -n +2 work/wicen/rt82vscan.csv >> work/wicen/rt82newscan.csv
    gsed -f bin/emptyrt82scan.gsed work/wicen/rt82newscan.csv > work/wicen/rt82xscan.csv
    awk -F";" '!_[$1]++' work/wicen/rt82xscan.csv > output/wicen/DMR/rt82scan.csv
    echo " Non uniq rt82 scan entries "
    diff work/wicen/rt82xscan.csv output/wicen/DMR/rt82scan.csv
    echo " End Non uniq scan entries "
    echo "Merge zones rt82"
    # merge the zones (not the scanlists!)
    gsed -f bin/emptyrt82.gsed -f bin/vhfuhf82.gsed work/wicen/rt82uzone.csv > work/wicen/rt82uxzone.csv
    #  tail -n +2 output/DMR/rt8vzone.csv | gsed -f bin/emptyrt82.gsed -f bin/vhfuhf82.gsed  > work/rt82vzone.csv
    gsed -f bin/emptyrt82.gsed -f bin/vhfuhf82.gsed work/wicen/rt82vzone.csv  > work/wicen/rt82vxzone.csv
    echo " create rt82new_fh.csv "
    bin/vkrepdzones.pl work/wicen/rt82uxzone.csv work/wicen/rt82vxzone.csv work/wicen/rt82
    # need to add single channels
    echo " update empty set of new_hf "
    gsed -f bin/emptyurt82w.gsed work/wicen/rt82newuhf.csv > output/wicen/DMR/rt82uzone.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/rt82uzone.csv
    gsed -f bin/emptyvrt82w.gsed work/wicen/rt82newvhf.csv > output/wicen/DMR/rt82vzone.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/rt82uzone.csv






    echo "Merging files for Anytone"
    echo " Merge channels 868"
    tail -n +2 work/wicen/868uchan.csv > work/wicen/868chan.csv
    tail -n +2 work/wicen/868vchan.csv >> work/wicen/868chan.csv

    echo '"No.","Channel Name","Receive Frequency","Transmit Frequency","Channel Type","Transmit Power","Band Width","CTCSS/DCS Decode","CTCSS/DCS Encode","Contact","Contact Call Type","Radio ID","Busy Lock/TX Permit","Squelch Mode","Optional Signal","DTMF ID","2Tone ID","5Tone ID","PTT ID","Color Code","Slot","Scan List","Receive Group List","TX Prohibit","Reverse","Simplex TDMA","TDMA Adaptive","AES Digital Encryption","Digital Encryption","Call Confirmation","Talk Around","Work Alone","Custom CTCSS","2TONE Decode","Ranging","Through Mode","Digi APRS RX","Analog APRS PTT Mode","Digital APRS PTT Mode","APRS Report Type","Digital APRS Report Channel","Correct Frequency[Hz]","SMS Confirmation","Exclude channel from roaming"' > output/wicen/DMR/868chan.csv

    sort --field-separator=',' -s --key=1,1 work/wicen/868chan.csv| cut -c3-  | awk '{print "\"" ++C "\",", $0 }' >> output/wicen/DMR/868chan.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/868chan.csv

    #| awk '{print "\"" ++C "\"", $0 }'

    echo " Merge channels 868 N0GSG"
    cat work/wicen/868uchann0gsg.csv > work/wicen/868chann0gsg.csv
    cat work/wicen/868vchann0gsg.csv >> work/wicen/868chann0gsg.csv
    sort --field-separator=',' -s --key=1,1 work/wicen/868chann0gsg.csv|cut -c2- > output/wicen/DMR/868chann0gsg.csv
    echo "merge scanlist 868"
    cat work/wicen/868uscan.csv > work/wicen/868scan.csv
    cat work/wicen/868vscan.csv >> work/wicen/868scan.csv
    echo '"No.","Scan List Name","Scan Channel Member","Scan Mode","Priority Channel Select","Priority Channel 1","Priority Channel 2","Revert Channel","Look Back Time A[s]","Look Back Time B[s]","Dropout Delay Time[s]","Dwell Time[s]"' > output/wicen/DMR/868scan.csv
    sort --field-separator=',' -s --key=1,1 work/wicen/868scan.csv| cut -c3-  | awk '{print "\"" ++C "\",", $0 }' >> output/wicen/DMR/868scan.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/868scan.csv
    echo "merge zonelist 868"
    cat work/wicen/868uzone.csv > work/wicen/868zone.csv
    cat work/wicen/868vzone.csv >> work/wicen/868zone.csv
    echo '"No.","Zone Name","Zone Channel Member","A Channel","B Channel"' > output/wicen/DMR/868zone.csv
    sort --field-separator=',' -s --key=1,1 work/wicen/868zone.csv| cut -c3-  | awk -f bin/zonemerge.awk | sed 's/" "/\|/' | awk -f bin/zonemerge2.awk | awk -F"," '$2 !~ $3{print}' | awk '{print "\"" ++C "\",", $0 }'  >> output/wicen/DMR/868zone.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/868zone.csv

    echo "# Process standard and wicen"
    #
    echo "Merge standard and wicen rt3"
    mv output/DMR/rt3uchann0gsg.csv  output/wicen/DMR/brt3uchann0gsg.csv
    cat output/wicen/DMR/rt3uchann0gsg.csv >>  output/wicen/DMR/brt3uchann0gsg.csv
    echo "Remove empty scan entries before merge"
    gsed -f bin/emptyrt3u.gsed output/DMR/rt3uscan.csv > work/wicen/brt3uxscan.csv
    tail -n +2 output/wicen/DMR/rt3uscan.csv | gsed -f bin/emptyrt3u.gsed >>  work/wicen/brt3uxscan.csv
    awk -F";" '!_[$1]++' work/wicen/brt3uxscan.csv > output/wicen/DMR/brt3uscan.csv
    echo " Non uniq brt3u scan entries "
    diff work/wicen/brt3uxscan.csv output/wicen/DMR/brt3uscan.csv
    echo " End Non uniq scan entries "

    mv output/DMR/rt3uzone.csv  work/wicen/brt3uxzone.csv
    tail -n +2 output/wicen/DMR/rt3uzone.csv >>  work/wicen/brt3uxzone.csv
    cat work/wicen/brt3uxzone.csv > output/wicen/DMR/brt3uzone.csv

##  echo "starting dzones.pl wrt"
##        bin/vkrepdzones.pl work/wicen/brt82uxzone.csv work/wicen/brt82vxzone.csv work/wicen/brt82
##    #
##    gsed -f bin/emptyurt82.gsed work/wicen/brt82newuhf.csv > output/wicen/DMR/brt82uzone.csv
##    gsed -f bin/emptyvrt82.gsed work/wicen/brt82newvhf.csv > output/wicen/DMR/brt82vzone.csv

if [ ! -d output/wicen/DMR/rt3 ] ; then mkdir output/wicen/DMR/rt3 ; fi
#rsync Defaults/Defrt3/ output/wicen/DMR/rt3/
#mv output/DMR/rt3tgroup.csv output/wicen/DMR/rt3/
#mv output/DMR/rt3rxgroup.csv output/wicen/DMR/rt3/
#mv output/DMR/rt3contacts.csv output/wicen/DMR/rt3/
cp output/DMR/cont-n0gsg.csv output/wicen/DMR/rt3/
mv output/wicen/DMR/rt3uchan.csv output/wicen/DMR/rt3/
mv output/wicen/DMR/rt3uchann0gsg.csv output/wicen/DMR/rt3/
mv output/wicen/DMR/rt3uscan.csv output/wicen/DMR/rt3/
mv output/wicen/DMR/rt3uzone.csv output/wicen/DMR/rt3/

if [ ! -d output/wicen/DMR/rt8 ] ; then mkdir output/wicen/DMR/rt8 ; fi
#rsync Defaults/Defrt8/ output/wicen/DMR/rt8/
#mv output/DMR/rt8tgroup.csv output/wicen/DMR/rt8/
#mv output/DMR/rt8rxgroup.csv output/wicen/DMR/rt8/
#mv output/DMR/rt8contacts.csv output/wicen/DMR/rt8/
cp output/DMR/cont-n0gsg.csv output/wicen/DMR/rt8/
mv output/wicen/DMR/rt8vchan.csv output/wicen/DMR/rt8/
mv output/wicen/DMR/rt8vchann0gsg.csv output/wicen/DMR/rt8/
mv output/wicen/DMR/rt8vscan.csv output/wicen/DMR/rt8/
mv output/wicen/DMR/rt8vzone.csv output/wicen/DMR/rt8/

echo "Merge standard and wicen rt82"

echo "Merging files for md2017"
echo " Merge channels rt82 DL5"
cat work/rt82chan.csv > work/wicen/brt82chan.csv
tail -n +2 work/wicen/rt82chan.csv >> work/wicen/brt82chan.csv
echo " Merge channels rt82 N0GSG"
cat work/rt82chann0gsg.csv > work/wicen/brt82chann0gsg.csv
cat work/wicen/rt82chann0gsg.csv >> work/wicen/brt82chann0gsg.csv

sort --field-separator=',' -s --key=1,1 work/wicen/brt82chan.csv | cut -c3-  > output/wicen/DMR/brt82chan.csv
sort --field-separator=',' -s --key=1,1 work/wicen/brt82chann0gsg.csv| cut -c3-  > output/wicen/DMR/brt82chann0gsg.csv
    #
    mv output/DMR/rt82scan.csv work/brt82xscan.csv
    tail -n +2 output/wicen/DMR/rt82scan.csv >>  work/brt82xscan.csv
    awk -F";" '!_[$1]++' work/brt82xscan.csv > output/wicen/DMR/brt82scan.csv
    echo " Non uniq brt82 scan entries "
    diff work/brt82xscan.csv output/wicen/DMR/brt82scan.csv
    echo " End Non uniq scan entries "
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/brt82scan.csv

    cat work/rt82uxzone.csv > work/wicen/brt82uxzone.csv
    tail -n +2 work/wicen/rt82uxzone.csv >>  work/wicen/brt82uxzone.csv
    cat work/rt82vxzone.csv  > work/wicen/brt82vxzone.csv
    tail -n +2 work/wicen/rt82vxzone.csv >>  work/wicen/brt82vxzone.csv
  echo "starting dzones.pl wrt"
        bin/vkrepdzones.pl work/wicen/brt82uxzone.csv work/wicen/brt82vxzone.csv work/wicen/brt82
    #
    gsed -f bin/emptyurt82.gsed work/wicen/brt82newuhf.csv > output/wicen/DMR/brt82uzone.csv
    gsed -f bin/emptyvrt82.gsed work/wicen/brt82newvhf.csv > output/wicen/DMR/brt82vzone.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/brt82uzone.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/brt82vzone.csv

    if [ ! -d output/wicen/DMR/rt82 ] ; then mkdir output/wicen/DMR/rt82 ; fi
    #rsync Defaults/Defrt82/ output/wicen/DMR/rt82/
    #mv output/DMR/rt82tgroup.csv output/wicen/DMR/rt82/
    #mv output/DMR/rt82rxgroup.csv output/wicen/DMR/rt82/
    mv output/DMR/rt82contacts.csv output/wicen/DMR/rt82/
    cp output/DMR/cont-n0gsg.csv output/wicen/DMR/rt82/
    mv output/wicen/DMR/brt82chan.csv output/wicen/DMR/rt82/
    mv output/wicen/DMR/brt82chann0gsg.csv output/wicen/DMR/rt82/
    mv output/wicen/DMR/brt82scan.csv output/wicen/DMR/rt82/
    mv output/wicen/DMR/brt82uzone.csv output/wicen/DMR/rt82/
    mv output/wicen/DMR/brt82vzone.csv output/wicen/DMR/rt82/


  echo "Merge standard and wicen 868"

        #
    cat work/868chan.csv > output/wicen/DMR/b868chan.csv
    cat work/wicen/868chan.csv >>  output/wicen/DMR/b868chan.csv

    mv output/DMR/868chann0gsg.csv  output/wicen/DMR/b868chann0gsg.csv
    cat output/wicen/DMR/868chann0gsg.csv >>  output/wicen/DMR/b868chann0gsg.csv

    cat work/868chan.csv > work/wicen/b868chan.csv
    cat work/wicen/868chan.csv >> work/wicen/b868chan.csv

    echo '"No.","Channel Name","Receive Frequency","Transmit Frequency","Channel Type","Transmit Power","Band Width","CTCSS/DCS Decode","CTCSS/DCS Encode","Contact","Contact Call Type","Radio ID","Busy Lock/TX Permit","Squelch Mode","Optional Signal","DTMF ID","2Tone ID","5Tone ID","PTT ID","Color Code","Slot","Scan List","Receive Group List","TX Prohibit","Reverse","Simplex TDMA","TDMA Adaptive","AES Digital Encryption","Digital Encryption","Call Confirmation","Talk Around","Work Alone","Custom CTCSS","2TONE Decode","Ranging","Through Mode","Digi APRS RX","Analog APRS PTT Mode","Digital APRS PTT Mode","APRS Report Type","Digital APRS Report Channel","Correct Frequency[Hz]","SMS Confirmation","Exclude channel from roaming"' > output/wicen/DMR/b868chan.csv

    sort --field-separator=',' -s --key=1,1 work/wicen/b868chan.csv| cut -c3-  | awk '{print "\"" ++C "\",", $0 }' >> output/wicen/DMR/b868chan.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/b868chan.csv

    cat work/868scan.csv > work/wicen/b868xscan.csv
    cat work/wicen/868scan.csv >> work/wicen/b868xscan.csv
    awk -F"," '$2 !~ $3{print}' work/wicen/b868xscan.csv > work/wicen/b868scan.csv


    echo '"No.","Scan List Name","Scan Channel Member","Scan Mode","Priority Channel Select","Priority Channel 1","Priority Channel 2","Revert Channel","Look Back Time A[s]","Look Back Time B[s]","Dropout Delay Time[s]","Dwell Time[s]"' > output/wicen/DMR/b868scan.csv
    sort --field-separator=',' -s --key=1,1 work/wicen/b868scan.csv| cut -c3-  | awk '{print "\"" ++C "\",", $0 }' >> output/wicen/DMR/b868scan.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/b868scan.csv

    echo "merge zonelist 868"
    cat work/868zone.csv > work/wicen/b868zone.csv
    cat work/wicen/868zone.csv >> work/wicen/b868zone.csv
    echo '"No.","Zone Name","Zone Channel Member","A Channel","B Channel"' > output/wicen/DMR/b868zone.csv
    sort --field-separator=',' -s --key=1,1 work/wicen/b868zone.csv| cut -c3-  | awk -f bin/zonemerge.awk | sed 's/" "/\|/' | awk -f bin/zonemerge2.awk | awk -F"," '$2 !~ $3{print}' | awk '{print "\"" ++C "\",", $0 }'  >> output/wicen/DMR/b868zone.csv
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/b868zone.csv

    if [ ! -d output/wicen/DMR/868 ] ; then mkdir output/wicen/DMR/868 ; fi
    rsync Defaults/Def878/* output/wicen/DMR/868/
    mv output/DMR/868tgroup.csv output/wicen/DMR/868/
    mv output/DMR/868rxgroup.csv output/wicen/DMR/868/
    mv output/DMR/868contacts.csv output/wicen/DMR/868/
    mv output/DMR/cont-n0gsg.csv output/wicen/DMR/868/
    mv output/wicen/DMR/b868chan.csv output/wicen/DMR/868/
    mv output/wicen/DMR/b868chann0gsg.csv output/wicen/DMR/868/
    mv output/wicen/DMR/b868scan.csv output/wicen/DMR/868/
    mv output/wicen/DMR/b868zone.csv output/wicen/DMR/868/
    perl -pi -e 's/\r\n|\n|\r/\r\n/g' output/wicen/DMR/868/BV878.LST


#        cat work/868uxzone.csv > work/wicen/b868uxzone.csv
#        tail -n +2 work/wicen/868uxzone.csv >>  work/wicen/b868uxzone.csv
#        cat work/868vxzone.csv  > work/wicen/b868vxzone.csv
#        tail -n +2 work/wicen/868vxzone.csv >>  work/wicen/b868vxzone.csv
#      echo "starting dzones.pl wrt"
#            bin/vkrepdzones.pl work/wicen/b868uxzone.csv work/wicen/b868vxzone.csv work/wicen/b868
        #
#        gsed -f bin/emptyurt82.gsed work/wicen/brt82newuhf.csv > output/wicen/DMR/brt82uzone.csv
 #       gsed -f bin/emptyvrt82.gsed work/wicen/brt82newvhf.csv > output/wicen/DMR/brt82vzone.csv





  fi
else
  echo "suppressed DMR"
fi
if [ ! -n "$publish" ] ;  then
  echo "starting the publish WP files"
  ./bin/publishWP.sh -r $repdate
  echo "starting the publish radio rsync and zip"
  ./bin/publish.sh
#  echo "starting the publish GoogleDocs files"
#  ./bin/publishGD.sh
#  echo "starting the publish S3 files"
#  ./bin/publishS3.sh
else
  echo "suppressed publishing"
fi
