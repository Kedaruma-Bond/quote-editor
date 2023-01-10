class Quote < ApplicationRecord
  has_many :line_item_dates, dependent: :destroy
  belongs_to :company
  has_many :line_items, through: :line_item_dates

  validates :name, presence: true
  
  scope :ordered, -> { order(id: :desc) }
  after_create_commit -> { broadcast_prepend_later_to [company, "quotes"], partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
  after_update_commit -> { broadcast_replace_later_to [company, "quotes"], partial: "quotes/quote", locals: { quote: self } }
  after_destroy_commit -> { broadcast_remove_to [company, "quotes"] }
  # Those three callbacks are equivalent to the following single line
  # broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

  def total_price
    line_items.sum(&:total_price)
  end
end
