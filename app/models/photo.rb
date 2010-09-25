class Photo < ActiveRecord::Base

  belongs_to :product

  MIN_DISPLAY_ORDER = 1
  MAX_DISPLAY_ORDER = 9

  before_destroy :unlink_photo

  scope :gallery_photo_for,
    lambda { |photo_id| where("full_photo_id = ?", photo_id)}

  scope :usage, lambda {|utype| where("usage_type = ?", utype)}
  scope :active, where("hidden = ?",  false)
  scope :sort_by_display_order, order("display_order ASC")

  validates_format_of :content_type, :with => /^image/,
  :message => "--- you can only upload pictures"

  def uploaded_photo=(photo_field)
    self.full_path = photo_field.original_filename
    self.file_name = base_part_of(photo_field.original_filename)
    self.content_type = photo_field.content_type.chomp
    self.data = photo_field.read
  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '' )
  end

  def unlink_photo
    if usage_type == 'Detail'
      # Find the gallery photo (if any) that points to this "Detail" photo
      # that is being deleted.  Null out its "full_photo_id" field.
      photos = Photo.gallery_photo_for(self.id)
      unless photos.empty?
        gallery_photo = photos[0]
        gallery_photo.update_attribute(:full_photo_id, nil)
      end
    end
  end

end
