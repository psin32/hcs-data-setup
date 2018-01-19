FROM mongo

COPY docker-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-start.sh

COPY catentries.json /usr/local/bin/
RUN chmod +x /usr/local/bin/catentries.json

COPY finalcategories.json /usr/local/bin/
RUN chmod +x /usr/local/bin/categories.json

WORKDIR /usr/local/bin

ENTRYPOINT [ "docker-loaddata.sh" ]

CMD ["mongod"]