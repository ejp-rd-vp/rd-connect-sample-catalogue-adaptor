# RD-Connect Sample Catalogue Adaptor

This is an adaptor for the RD-Connect Sample Catalogue to conform to the EJP-RD VP API.

## Running in Docker

To run this code create a docker-compose.yml file which defines the service:
```
version: "3.7"
services:
  rd-connect-catalogue-adaptor:
    build : .
    container_name: rd-connect-catalogue--adaptor
    environment:
      - ENVIRONMENT=production
      - localURL=http://ejprd.fair-dtls.surf-hosted.nl:8081
    ports:
      - 8081:80
    restart: unless-stopped
```
Make sure the localURL is set to the URL on which the service is exposed and that the port
is correctly mapped.

