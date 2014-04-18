class TagsController < ApplicationController

	def create
		@tag = Tag.where(name: params[:tag][:name]).first_or_create
		@photo = Photo.find(params[:photo_id])
		@photo.tags << @tag

		respond_to do |format|
			format.html { redirect_to photo_path(@photo) }
			format.js
		end
	end

	def destroy
		@tag = Tag.find(params[:id])
		@photo = Photo.find(params[:photo_id])
		@photo.tags.delete(@tag)

		respond_to do |format|
			format.html { redirect_to photo_path(@photo) }
			format.js
		end
	end

	def show
		@tag = Tag.find(params[:id])
	end

	private
	def tag_params
		params.require(:tag).permit(
			:name
		)
	end
end
