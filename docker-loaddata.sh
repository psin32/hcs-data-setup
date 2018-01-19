#!/bin/bash

mongodb1=`getent hosts ${MONGO1} | awk '{ print $1 }'`
mongodb2=`getent hosts ${MONGO2} | awk '{ print $1 }'`
mongodb3=`getent hosts ${MONGO3} | awk '{ print $1 }'`

port=${PORT:-27017}

echo "Waiting for startup.."
until mongo --host ${mongodb1}:${port} --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
  printf '.'
  sleep 1
done

echo "Started.."

echo setup.sh time now: `date +"%T" `

mongo --host ${mongodb1}:${port} <<-EOF
    rs.initiate({
       _id:"commercers",
       members:[
          {
             _id:1,
             host:"mongo1:27017"
          },
          {
             _id:2,
             host:"mongo2:27017"
          },
          {
             _id:3,
             host:"mongo3:27017"
          }
       ],
       settings:{
          getLastErrorDefaults:{
             w:"majority",
             wtimeout:30000
          }
       }
    });
EOF

sleep 3
mongo --host ${mongodb1}:${port} <<-EOF
    db.createUser({ user: "prashant", pwd: "root", roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWrite", db: "catalog" }, { role: "clusterAdmin", db: "admin" } ] });
    use catalog;
    db.createUser({ user: "prashant", pwd: "root", roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWrite", db: "catalog" }, { role: "clusterAdmin", db: "admin" } ] });
    use orders;
    db.createUser({ user: "prashant", pwd: "root", roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWrite", db: "orders" }, { role: "clusterAdmin", db: "admin" } ] });
    use payment;
    db.createUser({ user: "prashant", pwd: "root", roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWrite", db: "payment" }, { role: "clusterAdmin", db: "admin" } ] });
EOF

mongoimport --host ${mongodb1}:${port} --jsonArray --db catalog --collection category categories.json
mongoimport --host ${mongodb1}:${port} --jsonArray --db catalog --collection catentry catentries.json
mongoimport --host ${mongodb1}:${port} --jsonArray --db orders --collection shipping shipping.json

