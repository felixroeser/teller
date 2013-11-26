module Teller
  GLOBALS = {
  	mailer: {
  		default_from: 'teller@xilef.me'
  	},
  	locales: {
  		en: 'English',
  		de: 'Deutsch'
  	},
  	ffmpeg: {
  		threads: ENV['FFMPEG_MAX_THREADS'] || 1
  	}
  }.with_indifferent_access
end