class Fetcher::LibertyTimes < Fetcher
  def self.applicable?(url)
    url.include?('libertytimes.com.tw')
  end

  def initialize(url)
    @article = Article.new
    @article.url = url
    @raw = open(url).read
    @doc = Nokogiri::HTML(@raw)
    @encoding = :utf8
    if @doc.meta_encoding == 'big5'
      @raw = open(url).read.encode('utf-8', 'big5', :invalid => :replace, :undef => :replace, :replace => '')
      @doc = Nokogiri::HTML(@raw)
    @encoding = :big5
    end
  end

  #url = 'http://www.libertytimes.com.tw/2013/new/apr/13/today-sp2.htm'
  def fetch
    if @encoding == :big5
      @article.title = @doc.at_css('#newtitle').text
      @article.company_name = '自由時報'
      @article.content = @doc.css('#newsContent>span:not(#newtitle)>p:not(.picture)').text

      @article.reporter_name = parse_reporter_name()
      @article.published_at = Time.parse(@doc.at_css('#date').text)
      @article.url_id = @article.url[%r{http://www\.libertytimes\.com\.tw/(.*\.htm)},1]
    elsif @encoding == :utf8
      # new layout uses utf-8
      @article.title = @doc.at_css('#newsti').text
      @article.company_name = '自由時報'
      @article.content = @doc.css('#newsc.news_content').text

      time = @doc.at_css('.conttime').text[%r{\d{4}/\d{1,2}/\d{1,2} \d{2}:\d{2}}]
      if time.nil?
        match = @doc.at_css('.conttime').text.match(%r{(\d{2}):(\d{2})})
        @article.published_at = DateTime.now.change({:hour => match[1].to_i , :min => match[2].to_i , :sec => 0 })
      else
        @article.published_at = Time.parse("#{time}:00")
      end

      @article.reporter_name = parse_reporter_name()

      @article.url_id = @article.url[%r{news\.php?no=(\d+)},1]
    end

    clean_up

    @article
  end

  def parse_reporter_name
    if match = @article.content.match(%r{〔(.*?)[/／╱](.*?)〕})
      reporter_name = match[1][%r{記者(.+)},1]
    elsif match = @article.content.match(%r{記者(.+?)[/／╱]})
      reporter_name = match[1]
    elsif match = @article.content.match(%r{（文／(.*?)）})
      reporter_name = match[1]
    end
    reporter_name
  end

  def clean_url
    cleaner = UrlCleaner.new('no')
    @article.url = cleaner.clean(@article.url)
  end
end
