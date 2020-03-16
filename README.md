# wecube-docs

Documentation Site of WeCube

## How to build

In order to build the documentation site, you need to have python3 and pip installed, then do the following in the project directory:

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

## How to make changes

WeCube documentation site is powered by [MkDocs](https://www.mkdocs.org/) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

All documents and assets are located in the `docs` directory. You can find the site configuration in [mkdocs.yml](mkdocs.yml), please refer to [MkDocs site](https://www.mkdocs.org/user-guide/configuration/) for detailed information about those settings.

After making changes, please follow the "How to build" section to build and deploy the site.
