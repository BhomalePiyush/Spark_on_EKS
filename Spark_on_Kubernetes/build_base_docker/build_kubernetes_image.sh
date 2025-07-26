#!/bin/bash
apt-cache madison docker-ce | awk '{ print $3 }'
#chown root:root /var/run/docker.sock
#sudo service docker start
#sudo systemctl start docker
#usermod -aG docker $USER
sudo service docker restart
ls -l ./
sudo docker info
sudo service --status-all
sudo docker login -u ${DOCKER_REPO} -p ${DOCKER_PASSWORD}
echo "building image: $DOCKER_REPO"
sudo /opt/spark/bin/docker-image-tool.sh -r ${DOCKER_REPO} -t ${IMAGE_VERSION} \
-p /opt/spark/kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
sudo /opt/spark/bin/docker-image-tool.sh -r ${DOCKER_REPO} -t ${IMAGE_VERSION} \
-p /opt/spark/kubernetes/dockerfiles/spark/bindings/python/Dockerfile push