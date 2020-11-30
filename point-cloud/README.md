docker-compose up --build --remove-orphans  --abort-on-container-exit

docker-compose down -v

### init data
docker-compose exec -it data-loader /bin/bash
./data_loader.sh


