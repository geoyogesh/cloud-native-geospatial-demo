docker-compose up --build --remove-orphans

docker-compose down -v

### init data
docker exec -it data_loader_open_source /bin/bash
./data_loader.sh