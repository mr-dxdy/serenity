Odt-serenity
================

Serenity is an embedded ruby for OpenOffice documents (.odt files). You provide an .odt template with ruby code inside a special markup and the data and Serenity generates the document. If you know erb all of this should sound familiar.

Usage
======

Serenity is best demonstrated with an example. The first picture shows the template with the ruby code, next image shows the generated document. The template, output and the sample script can be found in the showcase directory.

![Serenity template](showcase/imgs/serenity_template.png?raw=true)

The image above is a screenshot of showcase.odt from the [showcase](showcase) directory. It's a regular OpenOffice document with ruby code embedded inside a special markup. That ruby code drives the document creation. You can use conditionals, loops, blocks &mdash; in fact, the whole ruby language and you can apply any OpenOffice formatting to the outputted variables or static text.

The second line in the template is `{%= @title%}` what means: output the value of variable title. It's bold and big, in fact, it's has the 'Heading 1' style applied. That variable will be replaced in the generated document, but it will still be a 'Heading 1'.

You can now take that template, provide the data and generate the final document:

``` ruby
require 'rubygems'
require 'serenity'

Person = Struct.new(:name, :items)
Item = Struct.new(:name, :usage)

class Showcase
  include Serenity::Generator

  def generate_odt
    @title = 'Serenity inventory'

    mals_items = [Item.new('Moses Brothers Self-Defense Engine Frontier Model B', 'Lock and load')]
    mal = Person.new('Malcolm Reynolds', mals_items)

    jaynes_items = [Item.new('Vera', 'Callahan full-bore auto-lock with a customized trigger, double cartridge and thorough gauge'),
                    Item.new('Lux', 'Ratatata'),
                    Item.new('Knife', 'Cut-throat')]
    jayne = Person.new('Jayne Cobb', jaynes_items)

    @crew = [mal, jayne]

    render_odt 'showcase.odt'
  end
end

# or alternative
class Showcase < ::SimpleDelegator
  include Serenity::Generator

  def initialize
    @title = 'Serenity inventory'

    mals_items = [Item.new('Moses Brothers Self-Defense Engine Frontier Model B', 'Lock and load')]
    mal = Person.new('Malcolm Reynolds', mals_items)

    jaynes_items = [Item.new('Vera', 'Callahan full-bore auto-lock with a customized trigger, double cartridge and thorough gauge'),
                    Item.new('Lux', 'Ratatata'),
                    Item.new('Knife', 'Cut-throat')]
    jayne = Person.new('Jayne Cobb', jaynes_items)

    @crew = [mal, jayne]

    super(self.helper)
  end

  def generate_odt
    render_odt 'showcase.odt'
  end
end
```

The key parts are `include Serenity::Generator` and `render_odt`. The data for the template must be provided as instance variables.

Following picture shows the generated document. It's a screenshot of the showcase_output.odt document from the [showcase](showcase) directory.

![Generated document](showcase/imgs/serenity_output.png)

Installation
============

``` ruby
  gem install odt-serenity
```

Examples
============

See examples of documents [here](fixtures).
