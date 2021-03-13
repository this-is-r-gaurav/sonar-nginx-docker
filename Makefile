mkfile_path := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
build:
	${mkfile_path}scripts/gen_cert.sh;
	${mkfile_path}scripts/gen_env_file.sh;
	${mkfile_path}scripts/gen_nginx_conf.sh;

clean:
	rm ${mkfile_path}certs/ca/*
	rm ${mkfile_path}certs/sonar/*
	rm ${mkfile_path}scanner/*.crt
	rm ${mkfile_path}env/*.env
	rm ${mkfile_path}nginx/nginx.conf

