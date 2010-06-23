class Article

  pname = {'na' => 'north america', 'la' => 'latin america'}

  def self.scrape(link, agent)
    article = self.new(link, agent)
    article.to_hash
  end

  def initialize(link, agent)
    @link = link
    @agent = agent
  end

  def page
    @page = @agent.get self.href
  end

  def content
    @content ||= begin
      content = page 
      content.root.search('script').remove
      content.root.search('noscript').remove
      content.root.search('a').remove
      content.root.css('div.banner').remove
      content.root.css('div#add-comment-container').remove
      content.root.css('div.content-image-full').remove
      content.root.css('div.content-image-float').remove
      content.root.css('p.back-to-top').remove
      content.root.xpath("//div[@class='col-left']").inner_html.squeeze(' ')
    end
  end

  def byline
    if page.root.css('div#content .top-border div.col-left h2')
      page.root.css('div#content .top-border div.col-left h2')[0].inner_html
    end
  end

  def href
    @link.href
  end

  def id
    @link.href[/story_id=([0-9]+)$/i, 1]
  end

  def section
    # http://www.economist.com/world/na/displaystory.cfm?story_id=14966121
    heading = @link.href[/\/([a-zA-Z]+)\/displaystory.cfm\?story_id=[0-9]+/, 1]
    PNAME[heading] || heading.capitalize rescue 'Briefings'
  end

  def title
    @link.text
  end

  def to_hash
    {
      :id => id, :title => title, :section => section, 
      :content => content, :byline => byline
    }
  end

end


