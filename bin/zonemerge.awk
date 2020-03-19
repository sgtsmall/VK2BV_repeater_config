
BEGIN { FS=","}
{k=$1;if(a[k])a[k]=a[k] OFS $2;else{a[k]=$1FS$2;b[++i]=k}}
END{for(x=1;x<=i;x++)print a[b[x]]}
