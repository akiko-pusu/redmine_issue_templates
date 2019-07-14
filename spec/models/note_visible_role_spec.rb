# frozen_string_literal: true

require_relative '../spec_helper'

describe NoteVisibleRole do
  let(:instance) { described_class.new }
  it 'Instance of NoteVisibleRole' do
    expect(instance).to be_an_instance_of(NoteVisibleRole)
  end
end
