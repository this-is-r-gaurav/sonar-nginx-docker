# SONAR-NGINX-DOCKER

This Repository contains scripts and dockerfiles, to setup a single node instance of sonarqube, behind nginx proxy over https.

## Pre-Requisite

* docker
* docker-compose
* stable internet connection :stuck_out_tongue_winking_eye:
* make (optional if you are doing Prebuild step with makefile )

## Specification

1. SonarQube Version:8.7.0-community
2. Sonar-Scanner Version: 4.6.0.2311
3. JAVA VERSION For Scanner: openjdk11-jre
4. NGINX Version  Latest
5. POSTGRES Version: 12

## Pre Build Steps

You can perform this step by following ways: 

1. Makefile
2. Manually 
 
### Makefile

Fill all the information mentioned in config.conf and execute make.

### Manually
Go to scripts directory and execute all the scripts  with following param
1. If you want to generate new self signed certificate for ca and sonar server execute script. 
```bash
./gen_cert.sh HOST_IP_ADDRESS COUNTRY STATE CITY ORG EMAIL
```
**Note:** If you already have those in handy with you just copy ca cert with name `root-ca.crt` in `certs/ca/root-ca.crt` and sonar-serer crt with name `sonar.crt` in `certs/sonar/sonar.crt`, relative to repo root directory, and also paste both certs with name mentioned above in `scanner/` directory.

2. Generate NGINX Config For The Host.
```bash
./gen_nginx_conf.sh HOST_NAME/HOST_IP_ADDRESS
```
3. Generate Environment Files For Docker Images.
```bash
./gen_env_file.sh POSTGRES_USERNAME POSTGRES_PASSWORD

```
## BUILD STEPS

1. Building Sonar Server.  
Go to Source Root and Execute the following command.
```bash
docker-compose -f docker-compose.yaml up -d
```
2. Buind Sonar Scanner Image.  
**Note:** There is generic sonar-project.properties existing in scanner directory, if you have specific requirement update the sonar-project.properties file before building the image
```bash
cd scanner
docker build -f scanner.dockerfile -t scanner_image_name .
```

## How to Scan. 
We need to mount the `project_code_dir` in `/workspace` inside container. In below command replace `{project_dir}` and `{absolute_path_of_project_dir_in_host}` with your code respective dir.

```bash
sudo docker run -v {absolute_path_of_project_dir_in_host}:/workspace/{project_dir} -it scanner_image_name SONAR_HOST_IP  SONAR_PROJECT_KEY SONAR_LOGIN_KEY_FOR_PROJECT
```

## Cleaning

To clean all thhe pre build files execute following:
```bash
make clean

```

## FAQ

1. Why we need to build image for sonar-scanner?  
Ans: In case of self-signed certificate you will required to build the image for sonar scanner in order to avoid adding server cert in java truststore for each machine you use to run the analysis. If you are scanning on a dedicated machine, or not using self signed certificate you can skip the step of building sonar-scanner image.

