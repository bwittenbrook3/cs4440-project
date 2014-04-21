class Photo
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  extend Dragonfly::Model
  field :image_uid, type: String 
  field :image_name, type: String

  dragonfly_accessor :image do
  	storage_options do |attachment|
      {
        path: "cs4440/photo/image/#{self.created_at}_#{self.image_name}",
        headers: {"x-amz-acl" => "public-read-write"}
      }
    end
  end

  searchkick
  has_and_belongs_to_many :tags
end
