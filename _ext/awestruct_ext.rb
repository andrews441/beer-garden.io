require 'asciidoctor'
require 'asciidoctor/extensions'
require 'awestruct/handlers/template/asciidoc'

# Monkeypatch the AsciidoctorTemplate class from Awestruct to register
# Asciidoctor::Document object in page context. Remove this hack when
# issue [1] will be resolved and available in a release.
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
end
