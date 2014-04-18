require 'test_helper'

class ArticleTest < Test::Unit::TestCase

  def test_create_article
    fake "blogs/1008414260/articles", :method => :post, :body => load_fixture('article')
    article = GainifyAPI::Article.new(:blog_id => 1008414260)
    article.save
    assert_equal "First Post", article.title
  end

  def test_get_article
    fake "articles/6242736", :method => :get, :body => load_fixture('article')
    article = GainifyAPI::Article.find(6242736)
    assert_equal "First Post", article.title
    assert_equal 1008414260, article.blog_id
  end

  def test_get_articles
    fake "articles", :method => :get, :body => load_fixture('articles')
    articles = GainifyAPI::Article.all
    assert_equal 3, articles.length
    assert_equal 1008414260, articles.first.blog_id
  end

  def test_get_articles_namespaced
    fake "blogs/1008414260/articles", :method => :get, :body => load_fixture('articles')
    articles = GainifyAPI::Article.find(:all, :params => {:blog_id => 1008414260})
    assert_equal 3, articles.length
    assert_equal 1008414260, articles.first.blog_id
  end

  def test_get_article_namespaced
    fake "blogs/1008414260/articles/6242736", :method => :get, :body => load_fixture('article')
    article = GainifyAPI::Article.find(6242736, :params => {:blog_id => 1008414260})
    assert_equal "First Post", article.title
    assert_equal 1008414260, article.blog_id
  end

  def test_get_authors
    fake "articles/authors", :method => :get, :body => load_fixture('authors')
    authors = GainifyAPI::Article.authors
    assert_equal "Gainify", authors.first
    assert_equal "development shop", authors.last
  end

  def test_get_authors_for_blog_id
    fake "blogs/1008414260/articles/authors", :method => :get, :body => load_fixture('authors')
    authors = GainifyAPI::Article.authors(:blog_id => 1008414260)
    assert_equal 3, authors.length
  end

  def test_get_tags
    fake "articles/tags", :method => :get, :body => load_fixture('tags')
    tags = GainifyAPI::Article.tags
    assert_equal "consequuntur", tags.first
    assert_equal "repellendus", tags.last
  end

  def test_get_tags_for_blog_id
    fake "blogs/1008414260/articles/tags", :method => :get, :body => load_fixture('tags')
    tags = GainifyAPI::Article.tags(:blog_id => 1008414260)
    assert_equal "consequuntur", tags.first
    assert_equal "repellendus", tags.last
  end

  def test_get_popular_tags
    fake "articles/tags.json?limit=1&popular=1", :extension => false, :method => :get, :body => load_fixture('tags')
    tags = GainifyAPI::Article.tags(:popular => 1, :limit => 1)
    assert_equal 3, tags.length
  end

end
