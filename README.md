# wecube-docs
documents of wecube

In order to build the document site, you need to have python3 and pip installed, then do the following in the project directory:

``` bash
# install mkdocs, themes, extensions, etc.
pip install -r requirements 

# you can build the site and get the static assets in the "site/" sub-directory
mkdocs build

# or, you can start up a local dev server and browse at http://127.0.0.1:8000 
mkdocs serve

# or, you can build and deploy the site to the "gh-pages" branch in the GitHub repository
mkdocs gh-deploy

####
```