require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  response_header "Cache-Control", "public, max-age=3600"
  protect_from_dos_attacks true
  secret "52ef5b115cd4c1be57f32a197f6688296f74f7fdf6225b43d97e56c93621efd8"

  url_format "/media/:job/:name"

  datastore :s3,
    bucket_name: 'fido-api-bucket',
    access_key_id: ENV['S3_KEY'],
    secret_access_key: ENV['S3_SECRET']

  # Override the .url method...
  define_url do |app, job, opts|
    thumb = Thumb.where(signature: job.signature).first
    # If (fetch 'some_uid' then resize to '40x40') has been stored already, give the datastore's remote url ...
    if thumb
      "http://d1g1dresthe9tw.cloudfront.net/#{thumb.uid}"
    # ...otherwise give the local Dragonfly server url
    else
      app.server.url_for(job)
    end
  end

  # Before serving from the local Dragonfly server...
  before_serve do |job, env|
    # ...store the thumbnail in the datastore...
    uid = job.store

    # ...keep track of its uid so next time we can serve directly from the datastore
    Thumb.create!(uid: uid, signature: job.signature)
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
