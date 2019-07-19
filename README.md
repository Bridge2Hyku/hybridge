# HyBridge

HyBridge is a ruby gem to ingest a batch of digital objects into the Samvera [Hyku](https://github.com/samvera-labs/hyku) application.

Part of the [Bridge2Hyku](https://bridge2hyku.github.io/) project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hybridge'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hybridge

Finally:

    $ rails g hybridge:install

### Hyku Settings

Add the following to your Hyku settings file in `config/settings.yml` or `config/settings/<environment>.yml`

```ruby
hybridge:
  filesystem: /path/to/ingest/packages
```

The HyBridge filesystem is the location where ingest packages will be stored for use in HyBridge. Create directories in the HyBridge filesystem location for every Multi tenant domain/repository installed using the repositories CNAME. Example: `/path/to/ingest/packages/myrepository.example.com`

## Usage

TODO: Write usage instructions here

## Development

TODO: Write development processes here

## License

**[Apache-2.0](LICENSE)**
