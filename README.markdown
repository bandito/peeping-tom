Installing
===============

Debian, Ubuntu: 

    sudo aptitude install xvfb xfonts-base xfonts-75dpi xfonts-100dpi imagemagick ttf-mscorefonts-installer python-qt4 python-qt4 python-pip build-essential python-setuptools flashplugin-installer ruby ruby1.8-dev irb rdoc redis-server git-core rubygems rake

    sudo gem install sinatra json resque
    sudo gem install redis -v "1.0.7"

    wget http://github.com/AdamN/python-webkit2png/raw/master/webkit2png.py
    sudo cp webkit2png.py /usr/bin/
    sudo chmod o+x /usr/bin/webkit2png.py

    git clone git://github.com/bandito/peeping-tom.git


The redis 2.0 driver doesn't currently work with resque (http://github.com/defunkt/resque/issues/110)

Usage
========
    #add a sample
    #ruby sample.rb
    QUEUE=* rake resque:work
    rescue-web #optional
    
    #run the webserver
    ruby server.rb

    wget http://localhost:4567/schedule?url=http://www.skroutz.gr&callback=http://www.mysite.com/handle_screenshot

The last statement will return a json string with the uid of the job and the location of the filename.

    {"url":"http://www.skroutz.gr","location":"/shots/127603/815c9bbfcea40f3afee068d398d95c3a-1276037080.png","jobid":"815c9bbfcea40f3afee068d398d95c3a-1276037080","callback":null}

When the screenshot is taken you will recieve a callback with the screenshots location as a parameter (as well as the id).

    http://www.mysite.com/handle_screenshot?uid=XXXXXXXXXXXXXXXX&location=XXXXXXXXXXXXXXXXX
