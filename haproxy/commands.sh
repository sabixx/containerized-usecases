docker stop /haproxy-container && docker rm /haproxy-container


docker run -d --name haproxy-container -v ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
-v /path/to/cert:/usr/local/etc/haproxy/certs:ro \
-p 443:443 -p 522:22 haproxy:latest


reload HA proxy without exiting....
kill -HUP 1


docker exec -it haproxy-container /bin/sh


docker run -d --name haproxy-container -p 37681:7681 -p 644:444 -p 445:445 -p 446:446 -p 447:447 -p 222:22 -e "PORT_COUNT=5" -e "HOSTNAME=myapp" -e "DOMAIN_NAME=tlsp.demo" haproxy-with-cert-gen


docker build -t haproxy-with-cert-gen .

docker tag haproxy-with-cert-gen:latest sabix/sshhaproxy:latest
docker push sabix/sshhaproxy:latest


