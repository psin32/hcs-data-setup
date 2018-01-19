FROM mongo

COPY docker-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-start.sh

COPY catentries.json /usr/local/bin/
RUN chmod +x /usr/local/bin/catentries.json

COPY categories.json /usr/local/bin/
RUN chmod +x /usr/local/bin/categories.json

COPY shipping.json /usr/local/bin/
RUN chmod +x /usr/local/bin/shipping.json

WORKDIR /usr/local/bin

ENTRYPOINT [ "docker-loaddata.sh" ]

CMD ["mongod"]