#default compose args
COMPOSE_ARGS=" -f jenkins.yml -p jenkins"
#make sure old container are gone
sudo docker compose $COMPOSE_ARGS stop
sudo docker compose $COMPOSE_ARGS rm --force -v

#Build the system
sudo docker-compose $COMPOSE_ARGS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d

#Run unittest
sudo docker compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
ERR=$?

#Run system if unittests passed 
if [ $ERR -eq 0 ]
then
   # Jenkinsコンテナをテスト用ネットワークに一時接続して通信可能にする
    sudo docker network connect jenkins_default my-jenkins || true
  IP=$(sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock-1)
    CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true
    # テスト用ネットワークから切断
    sudo docker network disconnect jenkins_default my-jenkins || true
    if [ $CODE -ne 200 ]
    then
      echo "Site returned " $CODE
        ERR=1
    fi
 fi
 
 #Pull down the system
 sudo docker compose $COMPOSE_ARGS stop
 sudo docker compose $COMPOSE_ARGS rm --force -v
 
 exit $ERR
