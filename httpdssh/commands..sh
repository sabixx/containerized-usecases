docker stop apache-ssl-container && docker rm apache-ssl-container

docker build -t sshhttpd .

docker tag sshhttpd:latest sabix/sshhttpd:latest
docker push sabix/sshhttpd:latest


docker run -d --name apache-ssl-container -e STARTP_PORT=30444 -e PORT_COUNT=5 -e HOSTNAME=myhttpdapp -e DOMAIN_NAME=tlsp.demo -p 37681:7681 -p 422:22 -p 444:30444 -p 445:30445 -p 446:30446 -p 447:30447 -p 448:30448 sshhttpd:latest 

docker exec -it apache-ssl-container /bin/sh