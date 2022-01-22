module NuPlugin
  module Data
    refine NilClass do
      def nuvalize
        Hash['Primitive', 'Nothing']
      end
    end

    refine TrueClass do
      def nuvalize
        val = (["0.33.1"].include?(ENV["NU_VERSION"]))  ? { 'Boolean' => 'true' } : { 'Boolean' => true }
        Hash['Primitive', val]
      end
    end

    refine FalseClass do
      def nuvalize
        val = (["0.33.1"].include?(ENV["NU_VERSION"]))  ? { 'Boolean' => 'false' } : { 'Boolean' => false }
        Hash['Primitive', val]
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
        val = (!["latest", "0.33.1", "0.37.1", "legacy"].include?(ENV["NU_VERSION"]))  ? { 'Int' => self.to_s } : { 'Int' => self }
        Hash['Primitive', val]
      end
    end

    refine Float do
      def nuvalize
        val = (["latest", "0.33.1", "0.37.1"].include?(ENV["NU_VERSION"]))  ? { 'Decimal' => self.to_s } : { 'Decimal' => self }
        Hash['Primitive', val]
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
