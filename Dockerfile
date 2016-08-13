FROM frolvlad/alpine-oraclejdk8:latest
# :slim is suspected to no have the javascript engine FROM frolvlad/alpine-oraclejdk8:slim

# Maintainer
# ----------
MAINTAINER David Filiatrault <david.filiatrault+docker@gmail.com>
# Credits
# Adapted from payaradocker/payaraserver which was ubuntu based
# Built via docker build -t fireballdwf/alpine-payara:latest .


# RUN apk add --update curl && rm -rf /var/cache/apk/*
RUN apk add --update ca-certificates openssl && rm -rf /var/cache/apk/*


#ENV PKG_VERSION 4.1.1.161.1
ENV PKG_VERSION 4.1.1.162
#ENV PKG_VERSION 4.1.1.154
ENV PKG_FILE_NAME payara-$PKG_VERSION.zip
ENV PAYARA_PKG https://s3-eu-west-1.amazonaws.com/payara.co/Payara+Downloads/Payara+$PKG_VERSION/$PKG_FILE_NAME
ENV GLASSFISH_INSTALL_DIR /opt/payara41/glassfish
ENV APPDOMAIN payaradomain

# add payara user, download payara nightly build and unzip
# RUN useradd -b /opt -m -s /bin/bash payara && echo payara:payara | chpasswd
RUN mkdir /opt && \
    adduser -D -s /bin/bash -h /opt/payara payara && echo payara:payara | chpasswd && \
    cd /opt && wget $PAYARA_PKG && unzip $PKG_FILE_NAME && rm $PKG_FILE_NAME && chown -R payara:payara /opt/payara41*

# Default payara ports to expose
EXPOSE 4848 8009 8080 8181

# Set up payara user and the home directory for the user
USER payara

WORKDIR $GLASSFISH_INSTALL_DIR/bin

# User: admin / Pass: glassfish
# enable secure admin to access DAS remotely. Note we are using the domain payaradomain
RUN echo "admin;{SSHA256}80e0NeB6XBWXsIPa7pT54D9JZ5DR5hGQV1kN1OAsgJePNXY6Pl0EIw==;asadmin" > $GLASSFISH_INSTALL_DIR/domains/$APPDOMAIN/config/admin-keyfile && \
    echo "AS_ADMIN_PASSWORD=glassfish" > pwdfile &&  \
    echo "export PATH=$PATH:$GLASSFISH_INSTALL_DIR/bin" >> /opt/payara/.bashrc && \
  ./asadmin start-domain $APPDOMAIN && \
  ./asadmin --user admin --passwordfile pwdfile enable-secure-admin && \
  ./asadmin stop-domain $APPDOMAIN
 
 

