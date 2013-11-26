class FillMetaOnPosting < ActiveRecord::Migration
  def up
    say "Updating geo and date on #{Posting.where(media_type: 'ImageFile').count} objects"
    Posting.where(media_type: 'ImageFile').includes(:media).each do |posting|
      image_file = posting.media
      next unless image_file.format == 'JPEG'

      exifr = EXIFR::JPEG.new("#{Rails.root}/public/i/#{image_file.id}/original.#{image_file.extension}")

      posting.recorded_at = exifr.date_time
      if exifr.gps.present?
        posting.geo_long = exifr.gps.latitude
        posting.geo_lat = exifr.gps.longitude
      end
      posting.save
    end
  end
end
