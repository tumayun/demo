class Phone
  include Mongoid::Document
  include Mongoid::Timestamps

  ## Fields
  field :name,              type: String
  field :user_id,           type: Integer
  field :locked,            type: Boolean,      default: false
  field :locked_at,         type: Time
  # 学校作息表, 默认是上午9点到下午15点
  field :school_schedule,   type: String,       default: '9-15'
  # 睡觉作息表, 默认是晚上23点到次日上午7点
  field :bed_schedule,      type: String,       default: '23-7'
  # 每日限制时间 默认3小时, 单位 hour
  field :daily_time,        type: Float,        default: 3

  ## Validates
  validates :name, :user_id, :locked, :school_schedule, :bed_schedule, :daily_time, presence: true
  validates :name,
    format: { with: /\A\w+\Z/, message: I18n.t('.allow_word', scope: 'errors.messages') },
    uniqueness: { case_sensitive: false, scope: :user_id }
  validates :daily_time, inclusion: { in: 0..24 }
  validate :validate_format_schedule

  ## Accessible
  attr_accessible :name, :school_schedule, :bed_schedule, :daily_time

  ## Callbacks
  before_save :set_locked_at

  ## Indexes
  index user_id: 1

  ## Relations
  belongs_to :user

  protected

  def validate_format_schedule
    { school_schedule: school_schedule, bed_schedule: bed_schedule }.each do |k, v|
      start_time, end_time = v.to_s.split('-')
      if start_time.blank? ||
        end_time.blank? ||
        start_time.to_i < 0 ||
        start_time.to_i > 24 ||
        end_time.to_i < 0 ||
        end_time.to_i > 24
        errors.add(k, '格式错误,只能是0到24之间')
      end
    end

    errors.empty?
  end

  def set_locked_at
    (self.locked_at = Time.now if locked.change?) and true
  end
end
