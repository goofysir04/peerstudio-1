class RubricItem < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :answer_attributes, :dependent => :destroy
  accepts_nested_attributes_for :answer_attributes, :allow_destroy => true, reject_if: proc { |attributes| attributes['description'].blank? }

  default_scope :order=>'ends_at ASC, open_at ASC, created_at ASC'

  validates :ends_at, presence: true
  validates :open_at, presence: true
end
