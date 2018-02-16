require 'asciidoctor'
require 'asciidoctor/extensions'
require 'awestruct/handlers/template/asciidoc'

# Monkeypatch the AsciidoctorTemplate class from Awestruct to register Asciidoctor::Document object in page context.
# Remove this hack when issue [1] will be resolved and available in a release.
# [1] https://github.com/awestruct/awestruct/issues/288
class Awestruct::Tilt::AsciidoctorTemplate
  def evaluate(scope, locals)
    @output ||= (scope.document = ::Asciidoctor.load(data, options)).convert
  end
end

Asciidoctor::Extensions.register do
  if (docfile = @document.attributes['docfile'])
    @document.instance_variable_set :@base_dir, File.dirname(docfile)
  end

  postprocessor do
    process do |doc, output|
      next output if (doc.attr? 'page-layout') || !(doc.attr? 'site-google_analytics_account')
      account_id = doc.attr 'site-google_analytics_account'
      %(#{output.rstrip.chomp('</html>').rstrip.chomp('</body>').chomp}
<script>
!function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m);}(window,document,'script','//www.google-analytics.com/analytics.js','ga'),ga('create','#{account_id}','auto'),ga('send','pageview');
</script>
</body>
</html>)
    end
  end unless ::Awestruct::Engine.instance.development?
end

module Awestruct
  class Engine
    def development?
      site.profile == 'development'
    end

    def generate_on_access?
      site.config.options.generate_on_access
    end
  end
end
