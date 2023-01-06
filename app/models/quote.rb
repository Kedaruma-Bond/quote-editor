class Quote < ApplicationRecord
  validates :name, presence: true
  
  scope :ordered, -> { order(id: :desc) }
  after_create_commit -> { broadcast_prepend_later_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
  after_update_commit -> { broadcast_replace_later_to "quotes", partial: "quotes/quote", locals: { quote: self } }
  after_destroy_commit -> { broadcast_remove_to "quotes" }
  # Those three callbacks are equivalent to the following single line でもわかりにくいですよね…
  # broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
end
