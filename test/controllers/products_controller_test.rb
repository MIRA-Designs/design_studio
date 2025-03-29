require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_path
    assert_response :success
  end

  test "should get new" do
    get new_product_path
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_path, params: { product: { category: @product.category, color: @product.color, description: @product.description, discount: @product.discount, mrp: @product.mrp, rating: @product.rating, size: @product.size, title: @product.title } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_path(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_path(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_path(@product), params: { product: { category: @product.category, color: @product.color, description: @product.description, discount: @product.discount, mrp: @product.mrp, rating: @product.rating, size: @product.size, title: @product.title } }
    assert_redirected_to product_url(@product)
  end
end
