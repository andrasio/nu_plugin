module Nu
  module Plugin
    module Data
      refine String do
        def nuvalize
      	  {"Primitive" => {"String" => self}}
        end
      end

      refine Integer do
        def nuvalize
      	  {"Primitive" => {"Int" => self}}
        end
      end

      refine Hash do
        def nuvalize
          fields = map do |k,v| 
            [k.to_s, Packing.tagged(tag).nuvalize(v)]
          end

          {"Row" => {"entries" => Hash[fields]}}
        end
      end

      refine Array do
        def nuvalize
          return {"Primitive" => "Nothing"} if empty?

          rows = map {|row| Packing.tagged(tag).nuvalize(row)}

          {"Table" => rows}
        end
      end

      refine NilClass do
        def nuvalize
          {"Primitive" => "Nothing"}
        end
      end
    end

    class Packing
      using Data

      attr_accessor :tag

      def item(value)
      	keys = value.keys

      	case
      	  when keys.include?("Row")
      	    row(value.fetch("Row"))
      	  else
      	    value.fetch("Primitive").values.first
      	end
      end

      def row(value)
      	{}.tap do |dictionary|
          value.fetch("entries").each_pair do |k,v|
            dictionary[k.to_sym] = rubytize(v)
          end
        end
      end

      def default_tag
      	{
      	  "origin"=>"00000000-0000-0000-0000-000000000000", 
      	  "span"=>{"start"=>5, "end"=>26}
        }
      end

      def tag
        @tag ||= {"tag" => default_tag}
      end

      def rubytize(tagged_value)
      	@tag = {
      		"tag" => tagged_value.fetch("tag") { default_tag }
        }
      	keys = tagged_value.keys

      	case
      	  when keys.include?("item")
            item(tagged_value.fetch("item"))
      	  when keys.include?("Row")
      	    row(tagged_value.fetch("Row"))
      	end
      end

      def nuvalize(value)
        meta = tag

        value.class.instance_eval do
          define_method :tag do
            meta
          end
        end

      	{"item" => value.nuvalize}.merge(tag)
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
