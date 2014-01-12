module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Label]
      # @param variable [String]
      #
      # @return [String]
      def render_label(item, node, variable = node.variable)
        return '' if variable.nil? || variable.empty?

        case
        when node.page?
          value, name = item.read_attribute(:page), :page
        when node.locator?
          value, name = item.locator, item.label
        when node.names_label?

          # We handle the editortranslator special case
          # by fetching editors since we can assume
          # that both are present and identical!
          if variable == :editortranslator
            value, name = item.data[:editor], variable.to_s
          else
            value, name = item.data[variable], variable.to_s
          end

        else
          value, name = item.data[variable], node.term
        end

        return '' if value.nil? || value.empty?

        options = node.attributes_for :form

        options[:plural] = case
          when node.always_pluralize?
            true
          when node.never_pluralize?
            false
          when node.number_of_pages?, node.number_of_volumes?
            value.to_i > 1
          when value.respond_to?(:plural?)
            value.plural?
          else
            CiteProc::Number.pluralize?(value.to_s)
          end

        translate name, options
      end

    end

  end
end
