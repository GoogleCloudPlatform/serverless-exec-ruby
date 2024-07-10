FROM ruby:3.3

WORKDIR /app

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get -y autoclean

ENV RACK_ENV=production

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . /app
EXPOSE 8080
CMD ["bundle", "exec", "ruby", "app.rb"]
