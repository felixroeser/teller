class VideoFile < ActiveRecord::Base
  has_one :posting, as: :media
  belongs_to :user

  after_destroy :remove_files

  def self.extensions
    %w(mp4 mov webm)
  end

  def self.extension_supported?(extension='')
    self.extensions.include?(extension.downcase)
  end

  def self.formats
    [:webm, :mp4]
  end

  def self.encoding_params
    {
      720 => {
        webm: {bitrate: 4000, abitrate: 192},
        mp4:  {profile: 'high', preset: 'slow', crf: 20, abitrate: 192}
        },
      480 => {
        webm: {bitrate: 2000},
        mp4:  {profile: 'baseline', preset: 'medium', crf: 23}
        },        
      360 => {
        webm: {bitrate: 1000},
        mp4:  {profile: 'baseline', preset: 'medium', crf: 23}
      }        
    }
  end

  # https://support.google.com/youtube/answer/1722171?hl=en
  def self.resolutions
    self.encoding_params
  end

  def out_path
    self.id ? "#{Rails.root}/public/v/#{self.id}" : nil
  end

  def remove_files
    FileUtils.rm_r out_path, force: true if out_path
  end

  # Put this in a decorator

  def poster_path(res=480)
    "/v/#{self.id}/poster_#{res}.png" if self.resolutions.include?(res.to_s)
  end

  def thumb_path(abs=false)
    !abs ? "/v/#{self.id}/thumb.png" : File.expand_path([Rails.root, 'public', "/v/#{self.id}/thumb.png" ].join('/'))
  end

  def video_path(format=:mp4, res=480)
    "/v/#{self.id}/#{res}.#{format}" if self.resolutions.include?(res.to_s)
  end

  def download_path(resolution='original')
    return unless resolution == 'original'

    "/v/#{self.id}/original.#{self.extension}"
  end

  def type(format=:mp4)
    "video/#{format}"
  end

  def landscape?
    self.orientation == 1
  end

  def portrait?
    !landscape?
  end

  def max_width_for(res=480)
    if landscape?
      900
    else
      res
    end
  end

end
