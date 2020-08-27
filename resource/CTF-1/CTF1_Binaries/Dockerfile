FROM ubuntu:16.04

RUN apt-get update && apt-get install -y openssh-server vim sudo postgresql postgresql-contrib
RUN mkdir /var/run/sshd
RUN echo 'root:test' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

##RUN adduser --disabled-password --gecos '' time
## Above is meant for creating a user and have the user ssh into that instead of root

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
COPY assignment1.sh /
RUN chmod +x assignment1.sh
COPY flags1.txt /
RUN bash assignment1.sh flags1.txt
RUN rm assignment1.sh
RUN rm flags1.txt
