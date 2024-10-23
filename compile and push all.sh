
cd haproxy/

docker build -t haproxy-with-cert-gen .
docker tag haproxy-with-cert-gen:latest sabix/sshhaproxy:latest
docker push sabix/sshhaproxy:latest

cd ..

cd ngnixssh/

docker build -t sshnginx .
docker tag sshnginx:latest sabix/sshnginx:latest
docker push sabix/sshnginx:latest

cd ..

cd httpdssh/

docker build -t sshhttpd .
docker tag sshhttpd:latest sabix/sshhttpd:latest
docker push sabix/sshhttpd:latest
 
cd ..

cd vcertnginx

docker build -t vcertnginx .
docker tag vcertnginx:latest sabix/vcertnginx:latest
docker push sabix/vcertnginx:latest

cd ..