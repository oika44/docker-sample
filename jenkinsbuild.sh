# Default compose args
COMPOSE_ARGS="-f jenkins.yml -p jenkins"

# Make sure old containers are gone
sudo docker compose $COMPOSE_ARGS stop
sudo docker compose $COMPOSE_ARGS rm --force -v

# Build the system
sudo docker compose $COMPOSE_ARGS build --no-cache
sudo docker compose $COMPOSE_ARGS up -d

# Run unit tests
sudo docker compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
ERR=$?

# Run system test if unit tests passed
if [ $ERR -eq 0 ]
then
    # Jenkinsコンテナをテスト用ネットワークに一時接続して通信可能にする
    sudo docker network connect jenkins_default my-jenkins || true
    
    # コンテナ名（identidock）を指定してHTTPステータスを確認
    CODE=$(curl -sL -w "%{http_code}" http://identidock:9090/monster/bla -o /dev/null) || true
    
    # テスト用ネットワークから切断
    sudo docker network disconnect jenkins_default my-jenkins || true

    if [ "$CODE" -ne 200 ]
    then
        echo "Site returned $CODE"
        ERR=1
    fi
fi

# Pull down the system
sudo docker compose $COMPOSE_ARGS stop
sudo docker compose $COMPOSE_ARGS rm --force -v

# テスト結果の終了コードをJenkinsに伝える
exit $ERR
# Pull down the system
sudo docker compose $COMPOSE_ARGS stop
sudo docker compose $COMPOSE_ARGS rm --force -v

# テスト結果の終了コードをJenkinsに伝える
exit $ERR

