#!/bin/bash

if [ -n "$MYID" ]; then
  echo ${MYID:-1} > /zookeeper/data/myid
else
  echo 1 > /zookeeper/data/myid
fi

if [ -n "$SERVERS" ]; then
	IFS=\, read -a servers <<<"$SERVERS"
	for i in "${!servers[@]}"; do
		# printf "&server.%i\\=%s:2888:3888" "$((1 + $i))" "${servers[$i]}" >> /exhibitor/exhibitor.properties
		printf "&server.$((1 + $i))\\=${servers[$i]}:2888:3888" >> /exhibitor/exhibitor.properties
	done
fi

# printf "&zookeeper.DigestAuthenticationProvider.superDigest\\=${ZOO_PASSWORD}" >> /exhibitor/exhibitor.properties
echo "&zookeeper.DigestAuthenticationProvider.superDigest\\=${ZOO_PASSWORD}" >> /exhibitor/exhibitor.properties

echo >> /exhibitor/exhibitor.properties

cat /exhibitor/exhibitor.properties

exec "$@"



