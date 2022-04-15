# frozen_string_literal: true

require 'test_helper'

class CredsAreMaskedTest < ActiveSupport::TestCase
  def test_a
    assert_equal 'lol_no', Rails.application.secrets.wat
    assert_equal 'lol_no', Rails.application.credentials.wat
  end
end
