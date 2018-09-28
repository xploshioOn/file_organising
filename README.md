# File Organising API

simple web-based application that allows users to upload files, organize them using tags, and then search for files using tags

## Installation

Download the app and run this to init the database structure

```ruby
rails db:create
rails db:migrate
```

and then start the application with

    rails s

you can make get requests with data, to /files if you want to create a file with tags, this is an example of data to create a file with tag3 and tag4 associated:

    {"name": "file5", "tags": ["tag3", "tag4"]}

you can make a search with /files/​:tag_search_query/:page, having in mind that the format of the query is a string containing a list of tags. Tags will be separated by whitespace and prefixed with either a + or a - sign. for example

    /files/+tag2 +tag3 -tag4/1

## Testing

the application has configured and is using RSpec as the testing framework, and using Factory Bot, Database Cleaner and Shoulda Matchers.

You can run the tests with

    bundle exec rspec

## Comments

* Changed file to document because file is a reserved word and can cause problems

* For the uuid we can use `uuid_generate_v4()` to have the uuid generated automagically by postgres activating the extension for this, but it depends if we want to use just postgres as database, it woulnd't be smooth as always to change the database with the ORM if we use specific database functions.

```ruby
    t.uuid   "uuid",      default: "uuid_generate_v4()"
```

* for the tags we don't let the user create a document if a tag is invalid, another course here can be ignore bad format tags or remove special characters. But because we don't have how to change the tags for a file, I found better to don't let this pass and let the user now to change the name of the tag without saving it.

* we don't let the users create a documents without tags because it's the only way to search for them.

* we validate that all the query string to search have specific format, and return a validation message if it doesn't have tags separated by space and starting with + or -. here we could ignore bad formats too and make the search with parts that match the format, but I saw better to validate the complete search query string.

* we validate that in the search query string we have at least one positive tag (+tag_name). because if there are just negative ones, we wouldn't get results.

* all requests are tested with rspec, taking care of all cases.
