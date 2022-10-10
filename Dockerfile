FROM fluent/fluentd:v1.15

USER root
RUN apk update
RUN apk add --no-cache --update --virtual .build-deps sudo build-base ruby-dev \
   && sudo gem install fluent-plugin-mongo \
   && sudo gem sources --clear-all \
   && apk del .build-deps \
   && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem
USER fluent
