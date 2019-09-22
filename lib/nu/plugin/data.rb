module Nu
  module Plugin
    module Data
      refine NilClass do
        def nuvalize
          Hash[ "Primitive", "Nothing" ]
        end
      end
      
      refine TrueClass do
        def nuvalize
          Hash[ "Primitive", {"Boolean" => "true"} ]
        end
      end

      refine FalseClass do
        def nuvalize
          Hash[ "Primitive", {"Boolean" => "false"} ]
        end
      end

      refine String do
        def nuvalize
      	  Hash[ "Primitive", {"String" => self} ]
        end
      end

      refine Integer do
        def nuvalize
      	  Hash[ "Primitive", {"Int" => self} ]
        end
      end

      refine Hash do
        def meta
          @meta ||= Packing.tagged(tag)
        end

        def nuvalize
          fields = map do |k,v| 
            [k.to_s, meta.nuvalize(v)]
          end

          Hash[ "Row", {"entries" => Hash[fields]} ]
        end
      end

      refine Array do
        def meta
          @meta ||= Packing.tagged(tag)
        end

        def nuvalize
          return {"Primitive" => "Nothing"} if empty?

          rows = map {|row| meta.nuvalize(row)}

          Hash[ "Table", rows ]
        end
      end
    end

    class Packing
      using Data

      attr_accessor :tag

      def nu_item(nu_value)
      	keys = nu_value.keys

      	case
      	  when keys.include?("Row")
      	    nu_row(nu_value.fetch("Row"))
          when keys.include?("Table")
            nu_table(nu_value.fetch("Table"))
          else
      	    begin
              nu_primitive = nu_value.fetch("Primitive")

              return nil if nu_primitive == "Nothing"
              nu_primitive.values.first
            end
      	end
      end

      def nu_row(nu_value)
      	{}.tap do |dictionary|
          nu_value.fetch("entries").each_pair do |name,nu_tagged_value|
            dictionary[name.to_sym] = nu_item(nu_tagged_value.fetch("item"))
          end
        end
      end

      def nu_table(nu_values)
        [].tap do |rows|
          nu_values.each do |nu_tagged_value|
            rows << nu_item(nu_tagged_value.fetch("item"))
          end
        end
      end

      def default_tag
      	{
      	  "origin"=>"00000000-0000-0000-0000-000000000000", 
      	  "span"=>{"start"=>0, "end"=>0}
        }
      end

      def tag
        @tag ||= {"tag" => default_tag}
      end

      def rubytize(nu_tagged_value)
      	nu_item(nu_tagged_value.fetch("item"))
      end

      def nuvalize(ruby_object)
        meta = tag

        ruby_object.class.instance_eval do
          define_method :tag do
            meta
          end
        end

      	{"item" => ruby_object.nuvalize}.merge(tag)
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
end
