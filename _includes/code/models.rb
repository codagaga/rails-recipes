# This convention puts the most important information about a model at the top.
class Project < ActiveRecord::Base

  # Include other modules
  # ---------------------
  # They add new behavior to the model. We want to know about this right away.
  include Project::HasPermissions

  # Rails macros
  # ------------
  # They, too add behavior to our model. Show them early on.
  acts_as_list
  default_scope order("name ASC")

  # ActiveRecord callbacks
  # ----------------------
  # AR callbacks should be used very sparingly and only if they comply with the
  # following rule:
  # "Use a callback only when the logic refers to state internal to the object."
  # In other words, there cannot be any external dependencies in the callback logic.
  # More details:
  # * http://samuelmullen.com/2013/05/the-problem-with-rails-callbacks/
  # * http://blog.bignerdranch.com/1658-the-only-acceptable-use-for-callbacks-in-rails-ever/
  #
  # It's also important to specify callbacks before associations in order for
  # inheritance to work for the callback queues. Otherwise, you might trigger
  # the loading of a child before the parent has registered the callbacks and
  # they won’t be inherited. (From Rails' ActiveRecord::Callbacks documentation)
  #
  # Sort the callbacks as required by model logic and add a comment indicating
  # why a callback's position is important.
  before_create :set_start_date # no dependencies, do this first
  before_save :update_duration # after set_start_date so we can use start date for calculation

  # ActiveRecord associations
  # -------------------------
  # They tell us how this model interacts with other models.
  #
  # * Sort the associations alphabetically, including the macro.
  #   Helps with detecting duplicates and finding them.
  # * Never go over 100 characters per line.
  # * Prefer has_many :through over has_and_belongs_to_many
  # * Always spell out the :dependent option explicitly on has_many associations
  #   to prove that you have thought about it.
  # * Always specify the :inverse_of option on associations.
  #   Helps eliminating some strange bugs when traversing the object graph
  #   in-memory and making changes.
  #   Except on :as, :through and :polymorphic associations. Doesn't work on those.
  belongs_to :client, :inverse_of => :projects
  has_many :collaborators, :dependent => :nullify, :inverse_of => :project
  has_many :todos, :order => "position ASC", :dependent => :destroy, :inverse_of => :project
  has_many :persons_responsible,
    :through => :collaborators,
    :uniq => true,
    :source => :person,
    :order => "persons.email ASC"

  # Validations
  # -----------
  validates_presence_of :name

  # Scopes
  # ------
  #
  # * Sort scopes alphabetically
  # * Never go over 100 characters per line.
  # * For complex scopes, put each element on a new line, put . on previous line
  #   to make multi-line unambiguous for parser on Ruby prior to 1.9.
  scope :active, where(:state => "active")
  scope :sorted_by lambda { |sort_key|
    case sort_key
    when "date_asc"; "projects.created_at ASC"
    ...
    end
  }
  scope :complicated,
    where("other_table.some_value = ?", value).
    order("position ASC").
    joins("other_table").
    limit(10)

  # Miscellaneous Declarations
  # --------------------------
  #
  # * attribute protection
  # * state_machine
  # * delegation
  #
  attr_protected :client_id
  alias_method ...
  # I prefer the demeter ruby extension over Rails' delegate for delegation.
  demeter :client_name, :to => :client, :using => :name

  # Class Methods
  # -------------
  #
  # I prefer the `def self.method_name` form. Shows the class context when 
  # looking at the method in isolation.
  # (e.g. as part of search results or symbol search in editor)
  def self.class_method_1
  end

  def self.class_method_2
  end

  # Instance Methods
  # ----------------
  #
  def instance_method_1(arg1)
  end

  def instance_method_2(arg1)
  end

  # **Protected Methods**: The `protected` keyword is not indented.
protected

  def protected_method
  end

  # **Private Methods**: The `private` keyword is not indented.
private

  def set_start_date
    self.started_at = Time.zone.now
  end

end
