This file specify how to create and install (uninstall) new layouts into wiki.

1. HOW TO CREATE NEW LAYOUT
-------------------------------------------------------------------------------
New layout must be packed into tar archiv and must contain this directory and
files structure:

layout_name.tar:

 layout_name
 layout_name\definition.yml
 layout_name\layout_name.html.erb
 layout_name\locales
 layout_name\public
 layout_name\public\images
 layout_name\public\layout_name.css


layout_name - directory to hold all needed files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

definition.yml - contains layout description and list of page parts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
example:
name: PeWe Layout
parts: [navigation, body, caption, footer]

layout_name.html.erb - html structure of layout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
possible parts are:
<%= render :partial => 'shared/header' %>
this part contains base html structure of head, javascript links and base css

<%= render :partial => 'shared/notice' %>
this part is responsible for users notification of actions done in wiki

<%= render :partial => 'shared/breadcrumb' %>
this is standard breadcumb navigation

<%= yield %>
this part generates all page parts defined for current page

<%= render :partial => 'shared/footer' %>
this is footer of html page, contains google analitics, closing tag for body and html elements


locales - directory which contains localization files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
example of localization file en.yml

en:
  layouts:
    pewe:  <-- name of layout
      description: "Some description"    <-- short description about layout
      parts:
        body: "main content"             <-- page part name and its description
        navigation: "page menu"          <-- page part name and its description
        caption: "caption of the page"   <-- page part name and its description
        footer: "number of users online" <-- page part name and its description


public - directory which contains stylesheet and directory with images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

images - directory for images files used in layout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

layout_name.css  - css stylesheet definition, file must be named as layout name with extension css
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





2. HOW TO INSTALL NEW LAYOUT
-------------------------------------------------------------------------------
To install new layout, run:
rake bonsai:install layout=full_path_to_layout.tar


3. HOW TO UNINSTALL LAYOUT
-------------------------------------------------------------------------------
To uninstall layout, run:
rake bonsai:uninstall layout=layout_name

Important: Just unused layouts can be uninstalled.

