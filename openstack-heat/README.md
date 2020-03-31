#openstack-heat

## postgresql

### create postgresql server and load data 

    openstack stack create -t postgresql.yaml --parameter key_name=<key_name> --parameter download_path=<download_path> --parameter file_list=<file_list> postgresql-1

### show the postgresql server internal ip address

    openstack stack output show postgresql-1 --all

### delete the postgresql server

    openstack stack delete postgresql-1 --yes