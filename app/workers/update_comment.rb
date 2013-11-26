class UpdateComment
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    comment = Comment.find_by_id opts[:id]

    case opts[:action]
    when 'created'
      after_created(comment)
    end
  end

  private

  def after_created(comment=nil)
    return if comment.blank?

    CommentsMailer.created(comment).deliver
  end

end
