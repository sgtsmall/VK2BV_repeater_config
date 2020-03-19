#!/bin/bash
echo "starting publish"
#DMR
mv    output/README_MD380.md output/DMR/
mv    output/README_MotoDMR.md output/DMR/

#Icom
#rsync Defaults/marinemem400.csv output/icombankx.csv
#rsync Defaults/icomyour.csv output/
#rsync Defaults/icomcall.csv output/
#rsync Defaults/g14.csv output/icomg14.csv

#Yaesu FT-1DR
if [ ! -d output/YAESU/FT-1D ] ; then mkdir output/YAESU/FT-1D ; fi
mv    output/README_FT_1D.md output/YAESU/FT-1D/
mv    output/YAESU/vkrepft-1dradms6.csv output/YAESU/FT-1D/

#Yaesu FT-2DR
if [ ! -d output/YAESU/FT-2D ] ; then mkdir output/YAESU/FT-2D ; fi
mv    output/README_FT_2D.md output/YAESU/FT-2D/
rsync Defaults/VKBV2D.rsf output/YAESU/FT-2D/
rsync Defaults/VKBV2D.FT2D output/YAESU/FT-2D/
mv    output/YAESU/vkrepft-2drrts.csv output/YAESU/FT-2D/

#Yaesu FTM-400D
if [ ! -d output/YAESU/FTM-400D ] ; then mkdir output/YAESU/FTM-400D ; fi
mv    output/README_FTM_400D.md output/YAESU/FTM-400D/
rsync Defaults/VKBV400.rsf output/YAESU/FTM-400D/
rsync Defaults/VKBV400.FTM400 output/YAESU/FTM-400D/
#rsync Defaults/README_FTM_400D.md output/YAESU/FTM-400D/
mv    output/YAESU/vkrepftm-400dradms7a.csv output/YAESU/FTM-400D/
mv    output/YAESU/vkrepftm-400dradms7b.csv output/YAESU/FTM-400D/
mv    output/YAESU/vkrepftm-400drrtsa.csv output/YAESU/FTM-400D/
mv    output/YAESU/vkrepftm-400drrtsb.csv output/YAESU/FTM-400D/
#
#
echo " publish zipping icom"
cd output/ICOM
zip -r IcomDStarplus *g3.csv *g14.csv *g22.csv *g23.csv *g24.csv icomm*.csv icomb*.csv icomyour.csv icomcall.csv
zip -r IcomDStar *g3.csv *g14.csv icomm*.csv icomb*.csv icomyour.csv icomcall.csv
sleep 5
rm icomg*.csv icomm*.csv icomb*.csv  icomyour.csv icomcall.csv
cd ../..

hereis=`pwd`
cd output/wicen/ICOM
for f in `ls -1 icom*`
 	do
	lines=$( wc -l < $f )
	if [ $lines = 1 ]
		then
			rm $f
	fi
	done
cd $hereis

if [ ! -d output/ICOM/ICOM_5100_12 ] ; then mkdir output/ICOM/ICOM_5100_12 ; fi
rsync output/ICOM/IcomDStarplus.zip output/ICOM/ICOM_5100_12/
mv output/README_ID_5100.md output/ICOM/ICOM_5100_12/

if [ ! -d output/ICOM/ICOM_51A_AnivPlus ] ; then mkdir output/ICOM/ICOM_51A_AnivPlus ; fi
rsync Defaults/README_ID_51A_P.gdoc output/ICOM/ICOM_51A_AnivPlus/
rsync output/ICOM/IcomDStarplus.zip output/ICOM/ICOM_51A_AnivPlus/
mv    output/README_ID_51A_P.md output/ICOM/ICOM_51A_AnivPlus/

if [ ! -d output/ICOM/ICOM_51A ] ; then mkdir output/ICOM/ICOM_51A ; fi
rsync Defaults/README_ID_51A.gdoc output/ICOM/ICOM_51A/
rsync output/ICOM/IcomDStar.zip output/ICOM/ICOM_51A/
mv    output/README_ID_51A.md output/ICOM/ICOM_51A/

rm output/DMR/*.zip
rm output/wicen/DMR/*.zip

echo " publish zipping 868"

cd output/DMR
zip -r 868 868
rm -r 868
cd ../..

echo " publish zipping rt82"

cd output/DMR
zip -r rt82 rt82
rm -r rt82
cd ../..

echo " publish zipping rt3"

cd output/DMR
zip -r rt3 rt3
rm -r rt3
cd ../..

echo " publish zipping rt8"

cd output/DMR
zip -r rt8 rt8
rm -r rt8
cd ../..

echo " publish zipping wicen 868"
cd output/wicen/DMR
rm 868*.csv
zip -r 868 868
rm -r 868
cd ../../..

echo " publish zipping wicen rt82"

cd output/wicen/DMR
rm rt82*.csv
zip -r rt82 rt82
rm -r rt82
cd ../../..

echo " publish zipping wicen rt3"

cd output/wicen/DMR
#rm rt82*.csv
zip -r rt3 rt3
rm -r rt3
cd ../../..

echo " publish zipping wicen rt8"

cd output/wicen/DMR
#rm rt82*.csv
zip -r rt8 rt8
rm -r rt8
cd ../../..

#cd output
#zip -r wicen wicen
#rm -r wicen
#cd ..
