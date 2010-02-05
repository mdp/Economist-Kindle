require 'rubygems'
require 'date'
require 'mechanize'
require 'haml'
require 'active_support'
require 'action_mailer'
require 'mailer'

class Article

  PNAME = {'na' => 'North America', 'la' => 'Latin America'}

  def initialize(link, agent)
    @link = link
    @agent = agent
  end

  def content
    @content ||= begin
      content = @agent.get self.href
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

end

class Magazine
  
  attr_reader :date, :html
  
  def self.build(sections, date)
    html = Haml::Engine.new(File.read('economist.html.haml')).render(Object.new, :sections => sections)
    self.new(html, date)
  end
  
  def self.load_backissue(date)
    html = File.read("editions/#{date.strftime('%d-%b-%Y')}-economist.html")
    self.new(html, date)
  end
  
  def initialize(html, date)
    @html = html
    @date = date
  end
  
  def archive
    File.open("editions/#{@date.strftime('%d-%b-%Y')}-economist.html", 'w').puts(html)
  end
  
  
  def mail(recipients)
    EconomistMailer.deliver_issue(recipients, "Economist - #{@date.strftime('%d %b %Y')}.html", html)
  end
  
end


class Scraper
  
  def self.scrape(email, pass)
    agent = WWW::Mechanize.new
    if File.exists?('cookies.yml')
      agent.cookie_jar.load('cookies.yml')
    end

    page = agent.get 'http://economist.com/printedition'

    if page.forms && page.forms.last.action =~ /payBarrier/
      p "Logging in"
      form.email_address = email
      form.pword = pass
      page = agent.submit form
      agent.cookie_jar.save_as('cookies.yml')
    end

    date = Date.parse(page.root.css('span.article-date').text)

    links = page.links.reject {|l| !(l.href =~ /story_id=[0-9]+$/i)}
    links.uniq!

    articles = links.collect { |l| Article.new(l, agent) }

    sections = ActiveSupport::OrderedHash.new
    articles.each do |article|
      sections[article.section] ||= []
      sections[article.section] << article
    end
    
    Magazine.build(sections, date)
  end

end



credentials = YAML.load_file('credentials.yml')['economist']
recipients = YAML.load_file('credentials.yml')['recipients']

magazine = Scraper.scrape(credentials[:email], credentials[:password])
magazine.archive

# magazine = Magazine.load_backissue(Date.parse("Dec-05-2009"))

magazine.mail(recipients)



