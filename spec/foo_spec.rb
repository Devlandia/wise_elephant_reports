# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../models/foo.rb', __FILE__

describe 'Foo' do
  it 'instantiate the method' do
    foo = Foo.new
    expect(foo.hello).to eql('world')
  end
end
