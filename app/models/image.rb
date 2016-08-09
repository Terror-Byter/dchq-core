class Image < ActiveRecord::Base
  IMAGE_STYLES = {
    'Company'             => { original: '512x512>', large: '128x128>', thumb: '64x64>', pdf: '200x75>' },
    'Store'            => { original: '512x512>' },
    'CertificationAgency' => { original: '512x512>', large: '128x128>',   thumb: '64x64>' },
    'Customer'            => { original: '512x512>', large: '128x128>', thumb: '64x64>' },
    'Brand'               => { original: '512x512>', large: '128x128>' },
    'Supplier'            => { original: '512x512>', large: '128x128>',  thumb: '64x64>' },
    'BusinessContact'     => { original: '512x512>', large: '128x128>', thumb: '64x64>' },
    'StoreProduct'        => { original: '512x512>', large: '128x128>', thumb: '64x64>' },
    'User'                => { original: '512x512>', large: '128x128>', thumb: '64x64>' }
  }
  has_paper_trail

  belongs_to :imageable, polymorphic: true

  attr_accessible :image, :imageable_type, :imageable_id

  has_attached_file :image,
                    styles:         ->(a){ IMAGE_STYLES[a.instance.imageable_type] },
                    url:            "/files/:imageable_type/:imageable_id/:style/:filename",
                    default_url:    '/assets/missing/:imageable_type/:style.gif'

  validates_attachment :image, content_type: { content_type: /^image/ }, size: { in: 0..2.megabytes }

  validates :imageable_id, uniqueness: { scope: :imageable_type }
  validates :imageable_type, inclusion: { in: IMAGE_STYLES.keys }

  Paperclip.interpolates :imageable_type do |attachment, style|
    type = attachment.instance.imageable_type

    if IMAGE_STYLES[type][style] || style.eql?(:original)
      attachment.instance.imageable_type.underscore
    else
      raise ":#{style} style for #{type} not exists!!!"
    end
  end

  Paperclip.interpolates :imageable_id do |attachment, style|
    attachment.instance.imageable_id
  end

  def short_content_type
    self.image.content_type[/.*\/(.*)/, 1]
  end

  def upload_image_from_url(url)
    self.image = open(url)
  end

  def upload_image(url)
    begin
      io = open(URI.escape(url))
      if io
        def io.original_filename; base_uri.path.split('/').last; end
        io.original_filename.blank? ? nil : io
        self.image = io
      end
      self.save(false)
    rescue Exception => e
      logger.info "EXCEPTION# #{e.message}"
    end
  end
end
