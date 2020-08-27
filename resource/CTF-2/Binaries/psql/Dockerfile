FROM postgres:12

#systemctl status postgresql
#COPY assignment1_PSQL.sh /
#RUN chmod +x assignment1_PSQL.sh
#COPY flags1.txt /
#RUN bash assignment1_PSQL.sh flags1.txt
#RUN rm assignment1_PSQL.sh
#RUN rm flags1.txt

#ENV POSTGRES_USER docker
#ENV POSTGRES_PASSWORD docker
#ENV POSTGRES_DB ctf2
ADD Create_CTF2_DB.sql /docker-entrypoint-initdb.d/
RUN echo "host    all all 0.0.0.0/0   trust" > /var/lib/postgresql/data/pg_hba.conf
EXPOSE 5432
