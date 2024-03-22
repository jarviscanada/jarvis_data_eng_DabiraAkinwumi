
#! /bin/bash

#assigning variables based on user arguements
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#setting env var for psql command
export PGPASSWORD=$psql_password

#getting usage data
lscpu_out=`lscpu`
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^[aA][rR][cC][hH][iI][tT][eE][cC][tT][uU][rR][eE]" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^[mM][oO][dD][eE][lL]\s[nN][aA][mM][eE]:" | awk '{$1=$2=""; print $0}'  | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^[cC][pP][uU]\s[mM][hH][zZ]:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out"  | egrep "^[lL]2\s[cC][aA][cC][hH][eE]" | awk '{$1=$2=""; print $0}'  | xargs | tr -d 'K')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date -u '+%F %H:%M:%S')

#writing sql query
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp) VALUES('$hostname','$cpu_number','$cpu_architecture','$cpu_model','$cpu_mhz','$l2_cache','$total_mem','$timestamp')"

psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit $?



