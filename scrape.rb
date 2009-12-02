require 'rubygems'
require 'date'
require 'mechanize'
require 'haml'
require 'activesupport'
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

agent = WWW::Mechanize.new
credentials = YAML.load_file('credentials.yml')['economist']
if File.exists?('cookies.yml')
  agent.cookie_jar.load('cookies.yml')
end

page = agent.get 'http://economist.com/printedition'

if page.forms && page.forms.last.action =~ /payBarrier/
  p "Logging in"
  form.email_address = credentials['email']
  form.pword = credentials['password']
  page = agent.submit form
  agent.cookie_jar.save_as('cookies.yml')
end

magazine_date = Date.parse(page.root.css('span.article-date').text)

links = page.links.reject {|l| !(l.href =~ /story_id=[0-9]+$/i)}
links.uniq!

articles = links.collect { |l| Article.new(l, agent) }

sections = ActiveSupport::OrderedHash.new
articles.each do |article|
  sections[article.section] ||= []
  sections[article.section] << article
end

magazine = Haml::Engine.new(File.read('economist.html.haml')).render(Object.new, :sections => sections)

File.open("editions/#{magazine_date.strftime('%d-%b-%Y')}-economist.html", 'w').puts(magazine)

recipients = YAML.load_file('credentials.yml')['recipients']
EconomistMailer.deliver_issue(recipients, "Economist - #{magazine_date.strftime('%d %b %Y')}.html", magazine)
