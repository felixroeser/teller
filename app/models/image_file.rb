class ImageFile < ActiveRecord::Base
  has_one :posting, as: :media
  belongs_to :user

  after_destroy :remove_files

  def self.extensions
    %w(png jpg jpeg)
  end

  def self.extension_supported?(extension='')
    self.extensions.include?(extension.downcase)
  end

  def self.resolutions
    {
      ultra:  {max: 2592},
      high:   {max: 1600},
      medium: {max: 1280},
      low:    {max: 800},
      thumb:  {max: 140}
    }
  end

  def out_path
    self.id ? "#{Rails.root}/public/i/#{self.id}" : nil
  end

  def remove_files
    FileUtils.rm_r out_path, force: true if out_path
  end

  # Put this in a decorator

  def thumb_path(abs=false)
    !abs ? image_path_for(:thumb) : File.expand_path([Rails.root, 'public', image_path_for(:thumb) ].join('/'))
  end

  def resolutions_biggest(smaller_than=nil)
    self.resolutions.first != 'thumb' ? self.resolutions.first : 'original'
  end

  # FIXME kinda ugly implementation
  def image_path_for(resolution_or_lower = 'medium')
    resolution_or_lower = resolution_or_lower.to_s

    if self.resolutions.index(resolution_or_lower).nil?
      res_keys = (ImageFile.resolutions.keys.map(&:to_s) & self.resolutions) - ['thumb']
      resolution_or_lower = res_keys[1] ? res_keys[1] : 'original'
    end

    "/i/#{self.id}/#{resolution_or_lower}.#{self.extension}"
  end

  def download_path(resolution='original')
    return unless resolution == 'original'

    "/i/#{self.id}/original.#{self.extension}"
  end
end
