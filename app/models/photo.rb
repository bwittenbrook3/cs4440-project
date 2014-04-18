class Photo
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  extend Dragonfly::Model
  field :image_uid, type: String 
  field :image_name, type: String
  dragonfly_accessor :image

  has_and_belongs_to_many :tags
end
