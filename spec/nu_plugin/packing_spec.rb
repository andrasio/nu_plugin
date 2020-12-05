require 'nu_plugin/packing'

describe NuPlugin::Packing do
  let(:nu_tag) {
    {
      'tag' => {
        'anchor' => '00000000-0000-0000-0000-000000000000',
        'span' => {
          'start' => 0,
          'end' => 3
        }
      }
    }
  }

  def nu_value(value)
    { 'value' => value }
  end

  def nu_tagged_value(value)
    nu_tag.merge(nu_value(value))
  end

  def nu_int(integer)
    Hash['Primitive', { 'Int' => integer.to_s }]
  end

  def nu_decimal(decimal)
    Hash['Primitive', { 'Decimal' => decimal.to_s }]
  end

  def nu_string(string)
    Hash['Primitive', { 'String' => string }]
  end

  let(:nu_nothing) {
    { 'Primitive' => 'Nothing' }
  }

  let(:nu_true) {
    Hash['Primitive', { 'Boolean' => 'true' }]
  }

  let(:nu_false) {
    Hash['Primitive', { 'Boolean' => 'false' }]
  }

  let(:nu_row) {
    {
      'Row' => {
        'entries' => {
          'name' => nu_value(nu_string('andres')),
          'tarif' => nu_value(nu_int(35))
        }
      }
    }
  }

  let(:nu_tagged_row) {
    {
      'Row' => {
        'entries' => {
          'name' => nu_tagged_value(nu_string('andres')),
          'tarif' => nu_tagged_value(nu_int(35))
        }
      }
    }
  }

  let(:nu_table) {
    Hash['Table', [nu_value(nu_row)]]
  }

  let(:nu_tagged_table) {
    Hash['Table', [nu_tagged_value(nu_tagged_row)]]
  }

  context 'unpacking' do
    let(:packer) { NuPlugin::Packing.new }

    it 'nothing' do
      value = nu_value(nu_nothing)
      expect(packer.rubytize(value)).to be_nil
    end

    it 'dates' do
      value = nu_value(nu_string("2020-11-16T00:00:00.000000000+00:00"))
      expect(packer.rubytize(value)).to eq('2020-11-16T00:00:00.000000000+00:00')
    end

    it 'integers' do
      value = nu_value(nu_int(35))
      expect(packer.rubytize(value)).to eql(35)
    end

    it 'decimals' do
      value = nu_value(nu_decimal(3.15))
      expect(packer.rubytize(value)).to eql(3.15)
    end

    it 'strings' do
      value = nu_value(nu_string('andres'))
      expect(packer.rubytize(value)).to eql('andres')
    end

    it 'symbols' do
      value = nu_value(nu_string(':andres'))
      expect(packer.rubytize(value)).to eql(:andres)
    end

    it 'tables' do
      value = nu_value(nu_table)
      expect(packer.rubytize(value)).to include({ name: 'andres', tarif: 35 })
    end

    it 'rows' do
      value = nu_value(nu_row)
      expect(packer.rubytize(value)[:name]).to eql('andres')
      expect(packer.rubytize(value)[:tarif]).to eql(35)
    end
  end

  context 'packing' do
    using NuPlugin::Data

    it 'nil objects' do
      expect(nil.nuvalize).to eql(nu_nothing)
      expect([].nuvalize).to eql(nu_nothing)
    end

    it 'dates' do
      require 'date'
      expect(DateTime.new(2020, 11, 16).nuvalize).to eql(nu_string("2020-11-16T00:00:00.000000000+00:00"))
    end

    it 'booleans' do
      expect(true.nuvalize).to eql(nu_true)
      expect(false.nuvalize).to eql(nu_false)
    end

    it 'integers' do
      expect(35.nuvalize).to eql(nu_int(35))
      expect(-1.nuvalize).to eql(nu_int(-1))
    end

    it 'decimals' do
      decimal = 3.15
      expect(decimal.nuvalize).to eql(nu_decimal(3.15))
    end

    it 'strings' do
      expect('andres'.nuvalize).to eql(nu_string('andres'))
    end

    it 'symbols' do
      expect(:andres.nuvalize).to eql(nu_string(':andres'))
      expect(':andres'.nuvalize).to eql(nu_string(':andres'))
    end

    it 'arrays' do
      data = [{ name: 'andres', tarif: 35 }]
      data.instance_variable_set('@meta', NuPlugin::Packing.tagged(nu_tag))
      expect(data.nuvalize).to eql(nu_tagged_table)
    end

    it 'hashes' do
      data = { name: 'andres', tarif: 35 }
      data.instance_variable_set('@meta', NuPlugin::Packing.tagged(nu_tag))
      expect(data.nuvalize).to eql(nu_tagged_row)
    end
  end

  context 'packing with metadata' do
    let(:with_metadata) { NuPlugin::Packing.tagged(nu_tag) }

    it 'nil objects' do
      expect(with_metadata.nuvalize(nil)).to eql(nu_tagged_value(nu_nothing))
    end

    it 'dates' do
      require 'date'
      expect(with_metadata.nuvalize(DateTime.new(2020, 11, 16))).to eql(nu_tagged_value(nu_string("2020-11-16T00:00:00.000000000+00:00")))
    end

    it 'boolean objects' do
      expect(with_metadata.nuvalize(true)).to eql(nu_tagged_value(nu_true))
      expect(with_metadata.nuvalize(false)).to eql(nu_tagged_value(nu_false))
    end

    it 'integers' do
      expect(with_metadata.nuvalize(35)).to eql(nu_tagged_value(nu_int(35)))
    end

    it 'decimals' do
      expect(with_metadata.nuvalize(3.15)).to eql(nu_tagged_value(nu_decimal(3.15)))
    end

    it 'strings' do
      expected = nu_tagged_value(nu_string('andres'))
      expect(with_metadata.nuvalize('andres')).to eql(expected)
    end

    it 'symbols' do
      expected = nu_tagged_value(nu_string(':andres'))
      expect(with_metadata.nuvalize(:andres)).to eql(expected)
    end

    it 'tables' do
      expected = nu_tagged_value(nu_tagged_table)
      expect(with_metadata.nuvalize([{ name: 'andres', tarif: 35 }])).to eql(expected)
    end

    it 'rows' do
      expected = nu_tagged_value(nu_tagged_row)
      expect(with_metadata.nuvalize({ name: 'andres', tarif: 35 })).to eql(expected)
    end
  end
end
