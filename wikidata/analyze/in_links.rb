#create a file similar to the binindex, but it stores the offsets all the files
#that link *to* a page.

#NB: each offset refers to the page's position  ***in the original
#binindex file***, not this one. We do not need to find a page's inlinks
#to more than one layer deep, so this is not a problem.

require_relative "verify.rb"
