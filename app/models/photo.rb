class Photo
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  extend Dragonfly::Model
  field :image_uid, type: String 
  field :image_name, type: String
  field :extended_tags_list, type: String

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

  def associated_tags
    associated_tags = Array.new
    self.tags.each do |tag|
      # check to see if tag is in redis
      syn_array = REDIS.get(tag.name)
      if !syn_array
        $URI = "http://words.bighugelabs.com/api/2/df2813b29aed08bcadb9ec1c2e987d40/#{tag.name.gsub(" ", "%20")}/json"
        response = Net::HTTP.get_response(URI.parse($URI))
        if response.body != "" && JSON.parse(response.body)["noun"]
          syn_array = JSON.parse(response.body)["noun"]["syn"] 
          REDIS.set(tag.name, syn_array)
          REDIS.expire(tag.name, 3600)
        else
          syn_array = []
        end
      else
        syn_array = eval(syn_array)
      end
      syn_array.each do |syn|
        associated_tags << syn
      end
    end

    associated_tags
  end
end
