require 'digest/sha1'
require 'base64'

class Hooks::MandrillController < ApplicationController
  protect_from_forgery except: :create

  def index
    head :ok
  end

  # f = File.read('spec/fixtures/mandrill/mail_with_one_png.json')
  # HTTParty.post('http://localhost:3000/hooks/mandrill', {body: {'mandrill_events' => f}})
  def create
    Rails.logger.info "Got mail from mandrill..."

    # File.open("/tmp/captured_#{Time.now.to_i}", "w") { |f| f.write params['mandrill_events'].to_json }

    success = process_payload(params)

    Rails.logger.info "...success? #{success}"

    render state: 200, json: {foo: :bar}
  end

  private

  def process_payload(payload)
    return false if params['mandrill_events'].blank?

    success = JSON.parse(params['mandrill_events']).
      select { |e| e['event'] == 'inbound'}.
      collect { |e| process_event(e) }.
      all? rescue nil
  end

  # FIXME move to a worker?
  def process_event(event)
    begin
      from_email = event['msg']['from_email']
      to_email = event['msg']['to'].map(&:first)

      # It's only supported to post to one user
      # Format: XXX DASH mail_token
      # FIXME use regex
      # TODO move stuff out of the controller!
      mail_tokens = to_email.collect { |s| s.split('@').first.split('-').last }.compact

      user = User.where(mail_token: mail_tokens).first
      # User must own an album
      album_ownership = user ? AlbumOwnership.where(user_id: user.id).first : nil

      unless user && album_ownership
        Rails.logger.info "...No user XOR album found for: #{mail_tokens.join(', ') }"
        return true
      end

      Rails.logger.info "... importing for #{user.id}"

      (event['msg']['attachments'] || {}).each do |file_name, attachment|
        type = attachment['type']
        extension = file_name.split('.').last

        unless ImageFile.extension_supported?(extension) || VideoFile.extension_supported?(extension)
          Rails.logger.info "...Extension #{type} / #{extension} not supported."
          next
        end

        decoded = Base64.decode64(attachment['content'])
        sha1 = Digest::SHA1.hexdigest(decoded)
        path = "/tmp/#{sha1}"
        FileUtils.mkdir_p path
        Rails.logger.info "...importing #{file_name} #{decoded.size} bytes into #{path}"

        File.open("#{path}/#{file_name}", 'wb') {|f| f.write(decoded)}

        Rails.logger.info '...write successful!'

        media = {
          file_name: file_name,
          extension: extension,
          full_path: "#{path}/#{file_name}",
          sha1:      sha1
        }

        enqueue_media(media, user)
      end

    rescue Exception => ex
      Rails.logger.error ex
      Rails.logger.error ex.backtrace.to_s
      return nil
    end

    true
  end

  def write_attachment()
  end

  def enqueue_media(media, user)
    ap ['Posting now:', media]    
    if ImageFile.extension_supported?(media[:extension])
      NewPostingFromImageFile.perform_async(media: media, user_id: user.id)
    elsif VideoFile.extension_supported?(media[:extension])
      NewPostingFromVideoFile.perform_async(media: media, user_id: user.id)
    end
  end

end
