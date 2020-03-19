function trim(s)
{
    gsub(/^[ \t]+|[ \t]+$/,"",s);
    gsub(/,/," ",s);
    gsub(/"/,"",s);
    return s ;
}
function trimtg(s,i)
{
    gsub(/^[ \t]+|[ \t]+$/,"",s);
    gsub(/,/," ",s);
    gsub(/"/,"",s);
    split(s,a,"|");
    return a[i] ;
}

BEGIN { FS=","}
{

printf "\"%s\",\"%s\",\"%s\",\"%s\"\n", trim($1), trim($2), trimtg($2,1), trimtg($2,2)
}
