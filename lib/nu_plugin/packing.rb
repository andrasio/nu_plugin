require 'nu_plugin/data'

module NuPlugin
  class Packing
    using Data

    attr_writer :tag

    def nu_item(nu_value)
      keys = nu_value.keys

      case
      when keys.include?('Row')
        nu_row(nu_value.fetch('Row'))
      when keys.include?('Table')
        nu_table(nu_value.fetch('Table'))
      else
        begin
          nu_primitive = nu_value.fetch('Primitive')

          return nil if nu_primitive == 'Nothing'

          if nu_primitive['String']
            str = nu_primitive['String']

            return str[1..].to_sym if str.start_with?(':')
            #return DateTime.iso8601(str)
          elsif nu_primitive['Int']
            return nu_primitive['Int'].to_i
          elsif nu_primitive['Decimal']
            return nu_primitive['Decimal'].to_f
          end
          
          nu_primitive.values.first
        rescue Date::Error
          nu_primitive.values.first
        end
      end
    end

    def nu_row(nu_value)
      {}.tap do |dictionary|
        nu_value.fetch('entries').each_pair do |name, nu_tagged_value|
          dictionary[name.to_sym] = nu_item(nu_tagged_value.fetch('value'))
        end
      end
    end

    def nu_table(nu_values)
      [].tap do |rows|
        nu_values.each do |nu_tagged_value|
          rows << nu_item(nu_tagged_value.fetch('value'))
        end
      end
    end

    def default_tag
      {
        'anchor' => nil,
        'span' => { 'start' => 0, 'end' => 0 }
      }
    end

    def tag
      @tag ||= { 'tag' => default_tag }
    end

    def rubytize(nu_tagged_value)
      nu_item(nu_tagged_value.fetch('value'))
    end

    def nuvalize(ruby_object)
      meta = tag

      ruby_object.class.instance_eval do
        define_method :tag do
          meta
        end
      end

      { 'value' => ruby_object.nuvalize }.merge(tag)
    end

    class << self
      def nuvalize(value)
        packer = new
        packer.nuvalize(value)
      end

      def tagged(tag)
        packer = new
        packer.tag = tag
        packer
      end
    end
  end
end
