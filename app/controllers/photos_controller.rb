class PhotosController < ApplicationController
	def index
		@photos = Photo.all.to_a
	end

	def new
		@photo = Photo.new
	end

	def create
		@photo = Photo.create(photo_params)
		redirect_to photo_path(@photo)
	end

	def show
		@photo = Photo.find(params[:id])
		@syns = @photo.associated_tags
		@similar = @photo.similar(fields: ["extended_tags_list"])
	end

	private
	def photo_params
		params.require(:photo).permit(
			:image
		)
	end
end
