require "sqlite3"

class File
  def each_chunk(chunk_size=1024*1024)
    yield read(chunk_size) until eof?
  end
end

class Graph
  HEADER_SIZE = 4
  def initialize(f,db_path, dbg = true)
    @debug = dbg
    debug "loading file"
    @d = []
    f.each_chunk do |chunk|
      @d.concat(chunk.unpack("L*"))
    end
    @db = SQLite3::Database.new db_path
  end

  def at(page,i)
    @d[page/4+i]
  end

  def link_count(page)
    at(page,1)
  end

  def bi_link_count(page)
    at(page,2)
  end

  def meta(page)
    at(page,3)
  end

  def page_links(page)
    x = page/4
    c = @d[x+1] # link count
    # print ("x:#{x}, c:#{c}, p:#{p}, HEADER_SIZE:#{HEADER_SIZE}")
    @d[x+HEADER_SIZE..x+HEADER_SIZE+c-1]
  end

  def page_bi_links(page)
    x = page/4
    c = @d[x+2] # bi link count
    @d[x+HEADER_SIZE..x+HEADER_SIZE+c-1]
  end

  def page_un_links(page)
    x = page/4
    b = @d[x+2] # bi link count
    c = @d[x+1] # bi link count
    @d[x+HEADER_SIZE+b..x+HEADER_SIZE+c-1]
  end

  def name(page)
    rs = @db.execute("SELECT title FROM pages WHERE offset = ? LIMIT 1",page)
    return nil if rs.empty?
    rs.first.first
  end

  def find(s)
    rs = @db.execute("SELECT offset FROM pages WHERE title = ? LIMIT 1",s)
    return nil if rs.empty?
    rs.first.first
  end


  def create_in_links
    #creates a hash where a key is the offest o a page and the value
    #is an array of offsets of pages linking to this page
    in_links = {}
    #using Sqlite3 in the short run, will switch to postgres in the near
    #future
    page_offsets = @db.execute("SELECT offset FROM pages")
    page_offsets.each_with_index do |page_offset, idx|
      puts idx if idx % 10000 == 0
      page_links(page_offset[0]).each do |out_link|
        if in_links[out_link]
          in_links[out_link] << page_offset[0]
        else
          in_links[out_link] = [page_offset[0]]
        end
      end
    end
    File.open('in_links.txt','w') do |f|
      f.write(in_links)
    end
  end

  private

  def debug(msg)
    STDERR.puts msg if @debug
  end
end
