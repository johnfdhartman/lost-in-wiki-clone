require_relative '../wikidata/analyze/graph.rb'
require 'sqlite3'
require 'multi_json'

#these methods turn the existing sqlite3 and JSON data into seeds
#for the postgres db

class SeedUtil

  def load_page_ranks
    page_ranks_txt = File.open('page_ranks.txt')
    page_ranks = MultiJson.open(page_ranks_txt)
    page_ranks_txt.close
    page_ranks
  end

  def load_pages
    old_db = SQLite3::Database.new('xindex-nocase.db')
    old_db.execute('SELECT * FROM pages')
  end

  def generate_seeds
    page_ranks = load_page_ranks
    pages = load_pages
    pages.each do |page|
      title, offset = page[0], page[1]
      page_rank = page_ranks[offset.to_s]
      newPage = Page.new(title: title, page_rank: page_rank)
      unless newPage.save
        puts "Page didn't save for some gorram reason"
      end
    end
  end
end
