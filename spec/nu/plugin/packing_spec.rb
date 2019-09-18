require "nu/plugin"

describe Nu::Plugin::Packing do
  let (:tagged_value) {
    {
      "tag" => {
          "origin" => "00000000-0000-0000-0000-000000000000",
          "span" => {
          	"start" => 0,
          	"end" => 4
          }
       }
    }
  }

  let (:int_value) {
    {"Primitive" => {"Int" => 2509000000}}
  }

  let (:string_value) {
    {"Primitive" => {"String" => "andres"}}
  }

  context "item unpacking" do
    it "unpacks a table" do
      value = tagged_value.merge({
        "Row" => {
          "entries" => {"name"  => tagged_value.merge("item" => string_value),
                        "tarif" => tagged_value.merge("item" => int_value) }
          }
      })

      data = Nu::Plugin::Packing.new
      expect(data.rubytize(value)[:name]).to eql("andres")
      expect(data.rubytize(value)[:tarif]).to eql(2509000000)
    end

    it "unpacks an integer" do
      value = tagged_value.merge "item" => int_value
      data = Nu::Plugin::Packing.new
      expect(data.rubytize(value)).to eql(2509000000)
    end

    it "unpacks a string" do
      value = tagged_value.merge "item" => string_value
      data = Nu::Plugin::Packing.new
      expect(data.rubytize(value)).to eql("andres")
    end
  end

  context "packing an item" do
    it "packs an integer" do
      value = 35
      data = Nu::Plugin::Packing.new
      expected = data.tag.merge({"item" => {"Primitive" => {"Int" => 35}}})
      expect(data.nuvalize(value)).to eql(expected)
    end

    it "packs a string" do
      value = "andres"
      data = Nu::Plugin::Packing.new
      expected = data.tag.merge({"item" => {"Primitive" => {"String" => "andres"}}})
      expect(data.nuvalize(value)).to eql(expected)
    end

    it "packs a table" do
      expected = tagged_value.merge({"item" => {
            "Row" => {"entries" => {"name"  => tagged_value.merge("item" => string_value),
                        "tarif" => tagged_value.merge("item" => int_value)}}
            }})

      data = Nu::Plugin::Packing.tagged(tagged_value)
      expect(data.nuvalize({name: "andres", tarif: 2509000000})).to eql(expected)
    end
  end
end
