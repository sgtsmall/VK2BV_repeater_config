#!/bin/bash
usage() {
echo "Usage: $(basename $0) -r repdate"
echo "  -r  repdate is YYMMDD from wia website"
echo "This script generates the html for website and places in output/WP"
echo " the next step is manual to actually update the site content"
}

pansed(){
today=`date "+%Y-%m-%d"`
mdfile=$1
gsed -e's/MDDATEFLD/Generated on '$today' with WIA data from '$repdate'/' Defaults/$mdfile.md > output/$mdfile.md
pandoc -f markdown_github output/$mdfile.md > work/$mdfile.htmlx
gsed -f bin/wp$mdfile.gsed work/$mdfile.htmlx > output/WP/$mdfile.html
}

mand=
if [ "$1" != "" ]; then
    args=$(getopt r: $*)
    if [ $? != 0 ] ; then usage ; exit 0 ; fi

    set -- $args

    for i
    do
        case "$i"
        in
            -r ) repdate=$2 ; mand=0 ; shift 2 ;;
            -h) usage ; exit 0 ;;
        esac
    done
fi
if [ ! -n "$mand" ] ; then
   usage
   exit 0
fi

pansed README_FT_1D
pansed README_FT_2D
pansed README_FTM_400D
pansed README_ID_51A
pansed README_ID_51A_P
pansed README_ID_5100
pansed README_MD380
pansed README_MotoDMR

#rm work/*.htmlx
