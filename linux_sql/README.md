# Linux Cluster Monitoring Agent


## Introduction

For this project I implemnted a program to record the hardware specifications of each node and monitor node resource usage of nodes within a linux cluster. This collected data is then stored in an RDBMS were it can referenced and used for resource planning purposes. The code for the project was written in a bash script, other technolgies used were git,postgresql and docker.


## Quick start commands
To start the project, execute the followig code:

In order to create and start a psql instance with docker:
```
./scripts/psql_docker.sh create db_username db_password

```

```
./scripts/psql_docker.sh start
```
 In order to create the neccessary sql tables to be able insert data:
```
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql

```
 To insert hardware specs data into the host info tables:
```
bash scripts/host_info.sh psql_host psql_port db_name psql_user psql_password

```
To insert hardware usage data into the host usage tables:
```
bash scripts/host_info.sh psql_host psql_port db_name psql_user psql_password
```
In order to setup cron to automate the program:

Within your bash shell run:
```
bash -e

```
Paste the following command in your cron tab
(make sure you are using the correct file path)
```
* * * * * bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```

## Implementation

The backend of this project was implemented using psql, so all the usage and specs data are stored in sql tables. For the sake of this project two tables are needed, one table to store the specs data and one to store the usage data. Docker was used to provision the psql tables. The actual code that inserts all the data and runs all the commands is done using a bash script. Finally cron is used to automate the running of the usage script, so every minute it runs the host usage script which checks the usage data and subsequently inserts it into the appropriate sql table.

## Architecture

![architecture] (./assets/architecture.jpg)

## Scripts
#### psql\_docker.sh: This script is used to either create, start or stop  an instance of psql using docker
Usage
```
./scripts/psql_docker.sh create db_username db_password

```

```
./scripts/psql_docker.sh start

```

```
./scripts/psql_docker.sh stop

```

#### host\_info.sh: This script collects hardware specification data and then inserts the data into the psql instance. We assume the hardware specifications is static so ideally this script will be executed only once.
Usage:
```
bash scripts/host_info.sh psql_host psql_port db_name psql_user psql_password

```

#### host\_usage.sh: This script collects server usage data and then inserts the data into the psql database. This script will be executed every minute using Linux's crontab program.

```
bash scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password

```

## Database Modeling

#### host\_info table

|column | description| data type|
|-------|------------|---------------------------------|
| id    | unique id for each row in the host info table| serial|
| hostname| name of cpu host| varchar|
| cpu\_number | number of cpus| int2 |
|cpu\_architecture| the architecture of the cpu processor| varchar|
|cpu\_model | the model of the cpu | varchar |
|cpu\_mhz | refers to the clock speed of a central processing unit (CPU), which determines how many instructions a processor can execute per second.| float8 |
|l2\_cache | L2 cache, or secondary cache of the cpu| int4|
|total\_mem | the total memory capacity of the cpu| int4|
|timestamp | time in which the data was inserted into psql | timestamp |


#### host\_usage table


|column| description| data type|
|------|------------|----------|
| timestamp | time data was inserted into the table | timestamp|
| host\_id | refers to the corresponding id in the host\_info table| serial|
| cpu\_idle | amount of time cpu has spent idle| int2|
| cpu\_kernel | time cpu has spent running kernel code| int2|
| disk\_io | number of IO's in progress | int4|
| disk\_available | number of disk space available | int4 |


## Test
I tested the ddl.sql file by executing it on the host\_agent database against the psql instance and then checking the corresponding sql tables to make sure the data was entered properly.

## Deployment
All the code is on github. The psql instance is hosted on docker and crontab is used to automate running the scripts

## Improvements

- more indepth log reports
- automatic alerts when usage is too high
- a user interface

