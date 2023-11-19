FROM ruby:3.0.1
RUN cd /tmp && curl -L --output ghr.tar.gz https://github.com/tcnksm/ghr/releases/download/v0.12.0/ghr_v0.12.0_linux_amd64.tar.gz && \
    tar -xzvf ghr.tar.gz && chmod +x ghr_v0.12.0_linux_amd64/ghr && mv ghr_v0.12.0_linux_amd64/ghr /usr/local/bin/ghr && rm -rf /tmp/*

WORKDIR /gem
COPY Gemfile /gem/Gemfile

COPY thor_enhance.gemspec /gem/thor_enhance.gemspec
COPY lib/thor_enhance/version.rb /gem/lib/thor_enhance/version.rb


RUN gem update --system && gem install bundler && bundle install --jobs=3 --retry=3 && \
    rm -rf /usr/local/bundle/cache

COPY . /gem
RUN gem build thor_enhance
