# frozen_string_literal: true

# This job prepends a message to the article body
AddNotesJob = Struct.new(:article_id) do
  def perform
    if article_id.nil?
      Article.all.each do |id|
        add_message_to_article id
      end
    else
      add_message_to_article article_id
    end
  end

  def add_message_to_article(id)
    article = Article.find_by_id(id)
    article.body = "Previous update #{article.updated_at} - #{Time.now.utc}\n#{article.body}"
    article.save!
    article.reload
  end

  def max_attempts
    1
  end
end
