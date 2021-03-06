require 'aws-sdk'

Aws.config[:credentials] = Aws::Credentials::new ENV['S3_ACCESS_KEY_ID'], ENV['S3_SECRET_ACCESS_KEY']

class Image < ActiveRecord::Base
  belongs_to :user
  attr_accessor :file

  before_create :save_file_info
  after_create :save_file
  before_destroy :destroy_file

  validates :user, presence: true
  validates :file, presence: true, on: :create

  def save_file_info
    self.filetype = file.content_type
    self.filename = file.original_filename
    self.filesize = file.size
    self
  end

  def save_file
    s3_bucket.put_object key: self.id, body: file
    self
  end

  def destroy_file
    obj = s3_bucket.object(self.id)
    return false unless obj
    deleted_object = s3_bucket.object "deleted/#{self.id}"
    obj.move_to deleted_object
    self
  end

  def url
    ENV['IMAGE_HOST_URL'] + id
  end

  private
    def s3_bucket
      unless @_s3_bucket
        s3_client = Aws::S3::Client.new region: ENV['S3_REGION']
        @_s3_bucket = Aws::S3::Bucket.new ENV['S3_BUCKET_NAME'], client: s3_client
      end
      @_s3_bucket
    end

end
