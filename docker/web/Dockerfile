# Берем готовый образ от swagger, внутри уже есть:
# - alpine 3.23.3
# - nginx 1.29.5
# - node 24.13.0
FROM swaggerapi/swagger-ui:v5.32.0

COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/templates/default.conf.template
