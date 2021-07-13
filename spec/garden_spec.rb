describe Garden do
  it "has access to the code for the Plant class" do
    expect { Garden.new(name: 'Front Lawn').plants }.not_to raise_error
  end
end
