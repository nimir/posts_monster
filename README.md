# Posts Monster

Hi, this monster will look for remote folders, download and unzip them then finally push content to a redis list. While skipping already fetched folders.

It is done by two methods in `lib/utils` wrapped in a `rake` task. The actualy downloading, unziping and pushing to `redis` is done in the background using `Sidekiq`

###We are using the following gems:

- open-uri
- nokogiri
- redis
- sidekiq

###You will need to do:

```bash
bundle install
```

###Prepare following directories:

```bash
mkdir data && mkdir data/tmp && mkdir data/posts
```

###Fire *Sidekiq*:

```bash
sidekiq -r ./lib/utils/job.rb
```

Then to start pulling posts, it's a simple rake task so running rake should fire it

```bash
rake
```