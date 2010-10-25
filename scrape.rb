require 'rubygems'
require 'date'
require 'yaml'
require 'mechanize'
require 'haml'
require 'active_support'
require 'action_mailer'
require 'article'
require 'magazine'
# require 'mailer'

class Scraper

  def self.scrape(email, pass)
    agent = Mechanize.new
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

    articles = links.collect { |l| 
      a = Article.scrape(l, agent, date)
      p "#{a[:section]} - #{a[:headline]}"
      a
    }

    File.open("editions/#{date.strftime('%d-%b-%Y')}.json", 'w').puts(articles.to_json)


  end

end



credentials = YAML.load_file('credentials.yml')['economist']
recipients = YAML.load_file('credentials.yml')['recipients']

magazine = Scraper.scrape(credentials[:email], credentials[:password])

# magazine = Magazine.load_backissue(Date.parse("Dec-05-2009"))

# magazine.mail(recipients)



