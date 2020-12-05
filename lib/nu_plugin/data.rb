module NuPlugin
  module Data
    refine NilClass do
      def nuvalize
        Hash['Primitive', 'Nothing']
      end
    end

    refine TrueClass do
      def nuvalize
        Hash['Primitive', { 'Boolean' => 'true' }]
      end
    end

    refine FalseClass do
      def nuvalize
        Hash['Primitive', { 'Boolean' => 'false' }]
      end
    end

    require 'date'

    refine Date do
      def nuvalize
        Hash['Primitive', { 'String' => self.iso8601(9) }]
      end
    end

    refine String do
      def nuvalize
        Hash['Primitive', { 'String' => self }]
      end
    end

    refine Symbol do
      def nuvalize
        Hash['Primitive', { 'String' => ":#{self}" }]
      end
    end

    refine Integer do
      def nuvalize
        Hash['Primitive', { 'Int' => self.to_s }]
      end
    end

    refine Float do
      def nuvalize
        Hash['Primitive', { 'Decimal' => self.to_s }]
      end
    end

    refine Hash do
      def meta
        @meta ||= Packing.tagged(tag)
      end

      def nuvalize
        fields = map do |k, v|
          [k.to_s, meta.nuvalize(v)]
        end

        Hash['Row', { 'entries' => Hash[fields] }]
      end
    end

    refine Array do
      def meta
        @meta ||= Packing.tagged(tag)
      end

      def nuvalize
        return { 'Primitive' => 'Nothing' } if empty?

        rows = map { |row| meta.nuvalize(row) }

        Hash['Table', rows]
      end
    end
  end
end
