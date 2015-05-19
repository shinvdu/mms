FROM rails:4.2.1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app


COPY . /usr/src/app
RUN bundle install

EXPOSE 3000

