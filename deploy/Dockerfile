# 
FROM composer:2.8

# Install dependencies


# Install Composer


# Set working directory
WORKDIR /var/www/html

# Copy files and install PHP deps

COPY . .

# Permissions Its taking more time. 
RUN chown -R www-data:www-data /var/www/html

RUN apk add --no-cache bash \
    && curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash \
    && apk add symfony-cli


RUN cd ./my_project

EXPOSE 8000

CMD ["symfony", "serve"]
