class Article

  def self.scrape(link, agent, date)
    article = self.new(link, agent, date)
    article.to_hash
  end

  def initialize(link, agent, date)
    @link = link
    @agent = agent
    @date = date
  end

  def page
    @page ||= @agent.get self.href
  end

  def content
    @content ||= begin
      content = page.root.css('div#ec-article-body div.ec-article-content')
      content.search('div').remove
      content.inner_html.strip
    end
  end

  def title
    page.root.css('div#ec-article-body h1').inner_html.strip
  end

  def headline
    page.root.css('div#ec-article-body .headline').inner_html.strip
  end

  def rubric
    if page.root.css('div#ec-article-body h2')
      page.root.css('div#ec-article-body h2')[0].inner_html.strip
    end
  end

  def href
    @link.href
  end

  def id
    @link.href[/story_id=([0-9]+)$/i, 1]
  end

  def section
    page.root.css('div#ec-article-body p.ec-article-info')[1].inner_html.strip
  end

  def to_hash
    {
      :id => id, :title => title, :section => section,
      :content => content, :headline => headline, :rubric => rubric,
      :edition_date => @date.to_s
    }
  end

end


