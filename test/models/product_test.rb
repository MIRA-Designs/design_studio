require "test_helper"
include ActionDispatch::TestProcess

class ProductTest < ActiveSupport::TestCase
  test "process_images should reattach existing image IDs as blobs" do
    product = products(:one)
    existing_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("test/fixtures/files/sample.jpg")),
      filename: "sample.jpg",
      content_type: "image/jpeg",
      key: "one"
    )

    # Simulate existing image ID
    image_params = [ existing_blob.id ]

    assert_difference -> { product.images.count }, 1 do
      product.process_images(image_params)
    end

    assert product.images.attachments.any? { |attachment| attachment.blob_id == existing_blob.id }
  end

  test "process_images should ignore invalid image IDs" do
    product = products(:one)

    # Simulate invalid image ID
    image_params = [ 0, -1, "invalid" ]

    assert_no_difference -> { product.images.count } do
      product.process_images(image_params)
    end
  end

  test "process_images should attach new uploaded images" do
    product = products(:one)

    # Create a Tempfile instance
    tempfile = Tempfile.new([ "test/fixtures/files/sample", ".jpg" ]) # ['basename', '.extension']
    tempfile.rewind

    # Create an UploadedFile instance
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: "sample.jpg", # Original filename
      type: "image/jpeg",      # MIME type
      head: "Content-Disposition: form-data; name=\"file\"; filename=\"sample.jpg\"\r\nContent-Type: image/jpeg\r\n"
    )
    # Simulate new uploaded image
    image_params = [ uploaded_file ]

    assert_difference -> { product.images.count }, 1 do
      product.process_images(image_params)
    end

    assert product.images.attachments.any? { |attachment| attachment.blob.filename.to_s == "sample.jpg" }
  end
end
