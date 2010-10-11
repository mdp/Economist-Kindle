require 'time'
require 'json'
require 'haml'

class Magazine

  attr_reader :date, :articles

  def self.load(date)
    article_list = JSON.parse(File.open("#{File.dirname(__FILE__)}/editions/#{date.strftime('%d-%b-%Y')}/contents.json"))
    return Magazine.new(article_list, date)
  end

  # Takes content as yaml
  def initialize(articles, date)
    @articles = articles
    @date = date
  end

  def archive
    File.open("editions/#{date.strftime('%d-%b-%Y')}/contents.yml", 'w').puts(articles.to_yaml)
  end

  def sections
    sections = {}
    articles.each do |article|
      sections[article[:section]] ||= []
      sections[article[:section]] << article
    end
    sections
  end

  def html
    html = Haml::Engine.new(File.read("#{File.dirname(__FILE__)}/economist.html.haml")).render(
	      Object.new, :sections => sections)
  end

end

