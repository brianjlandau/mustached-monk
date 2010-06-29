# Nice 'n' Easy

> "Lets take it nice and easy  
> Its gonna be so easy  
> ...  
> cause nice and easy does it every time"

A set of Sinatra HTML view helpers to make your life nicer and easier.
It includes helpers for form fields, links, and assets.

In designing the library I tried to limit my use of external libs as much as possible.
In particular, I found a number of similar Sinatra HTML helpers but a number included all of
ActiveSupport.
ActiveSupport's "blank" functionality is included here, and I copy "`extract_options!`" and
"`symbolize_keys`" from there too but I add nothing else. Although if you include
ActiveSupport yourself the `label` helper will take advantage of the `titleize` method.


## Install & Usage

Install:

    sudo gem install nice-n-easy --source http://gemcutter.org

Add this to your Sinatra app:

    require 'sinatra/nice_easy_helpers'
    
    class Main < Sinatra::Base
      helpers Sinatra::NiceEasyHelpers
    end

See the [RDocs](http://brianjlandau.github.com/nice-n-easy/) for how to use the individual helpers


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009 Brian Landau. See LICENSE for details.
