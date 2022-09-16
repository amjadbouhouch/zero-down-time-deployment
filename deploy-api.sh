#!/bin/bash
nginx_service_name=nginx
nginx_container_id=$(docker ps -f name=$nginx_service_name -q | tail -n1)
reload_nginx() {  
  docker exec $nginx_container_id /usr/sbin/nginx -s reload  
}


zero_downtime_deploy() {  
  service_name=api  
  old_container_id=$(docker ps -f name=$service_name -q | tail -n1)

  # bring a new container online, running new code  
  # (nginx continues routing to the old container only)  
  docker-compose up -d --no-deps --scale $service_name=2 --no-recreate $service_name

  # wait for new container to be available  
  new_container_id=$(docker ps -f name=$service_name -q | head -n1)
  new_container_helth_check=$(docker inspect -f '{{ .State.Health.Status }}' $new_container_id)
 
  
  while [ ["${new_container_helth_check}" != "healthy"] ]
  do
    echo "waiting for container ${new_container_id} to be healthy"
    
    sleep 5
    new_container_helth_check=$(docker inspect -f '{{ .State.Health.Status }}' $new_container_id)
  done
  # start routing requests to the new container (as well as the old)  
  reload_nginx

  # take the old container offline  
  docker stop $old_container_id
  docker rm $old_container_id
  # 
  docker-compose up -d --no-deps --scale $service_name=1 --no-recreate $service_name

  # stop routing requests to the old container  
  reload_nginx  
}
zero_downtime_deploy