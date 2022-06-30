FROM nginx:1.23
MAINTAINER "Amin Fazlali <amin@fazlali.net>"


# Install the NGINX Amplify Agent
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
	apt-get update && apt-get install -qy apt-utils --no-install-recommends && \
	apt-get install -qy gnupg2 && \
	curl -fs http://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx.gpg > /dev/null 2>&1 && \
	echo "deb [signed-by=/usr/share/keyrings/nginx.gpg] https://packages.amplify.nginx.com/py3/debian/ bullseye amplify-agent" > /etc/apt/sources.list.d/nginx-amplify.list && \
	apt-get update && apt-get install -qy nginx-amplify-agent && \
	apt-get purge -qy curl apt-transport-https apt-utils gnupg2 && \
	rm -rf /etc/apt/sources.list.d/nginx-amplify.list

RUN unlink /var/log/nginx/access.log \
    && unlink /var/log/nginx/error.log \
    && touch /var/log/nginx/access.log \
    && touch /var/log/nginx/error.log \
    && chown nginx /var/log/nginx/*log \
    && chmod 644 /var/log/nginx/*log

COPY ./stub_status.conf /etc/nginx/conf.d

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]