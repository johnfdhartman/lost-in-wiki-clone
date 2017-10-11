class Page < ApplicationRecord

  def self.destroy_meta_pages
      #destroys all pages that begin with Category:, Wikipedia:,
      #MediaWiki: or contain (disambiguation)
      Page.where("
        title SIMILAR TO
          '(Wikipedia\:|Category\:|MediaWiki\:|Portal\:)%'
        OR title SIMILAR TO '%disambiguation%'")
        .destroy
  end
end
